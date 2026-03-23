# nix run .#update-pipelines
{
  flake-self,
  lib,
  pkgs,
  ...
}:
let
  # Map platform names between woodpecker and nix
  platforms = {
    "aarch64-linux" = "linux/arm64";
    "x86_64-linux" = "linux/amd64";
  };

  machines = builtins.attrNames (
    lib.filterAttrs (name: config: config.config.paul.ci.enable) flake-self.nixosConfigurations
  );

  systemFor = name: flake-self.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system;

  machinesFor = system: builtins.filter (name: systemFor name == system) machines;

  nix-fast-build = "nix-fast-build --no-nom --skip-cached --attic-cache lounge-rocks:nix-cache";

  steps = {
    decryptPrivateData = {
      name = "Decrypt Private Data";
      image = "bash";
      commands = [
        "cd modules/private"
        "echo $AGE_KEY_PRIVATE_DATA | nix shell nixpkgs#age --command age --decrypt -i - -o private.toml.decrypted private.toml"
        "mv private.toml.decrypted private.toml"
      ];
      environment.AGE_KEY_PRIVATE_DATA.from_secret = "AGE_KEY_PRIVATE_DATA";
    };

    atticSetup = {
      name = "Setup Attic";
      image = "bash";
      commands = [
        "attic login lounge-rocks https://cache.lounge.rocks $ATTIC_KEY --set-default"
      ];
      environment.ATTIC_KEY.from_secret = "attic_key";
    };

    buildAllMachinesFor = system: {
      name = "Build all ${system} machines";
      image = "bash";
      failure = "ignore";
      commands = [
        "${nix-fast-build} --flake \".#checks.${system}\""
      ];
    };

    checkMachineOutput = name: {
      name = "check-output-${name}";
      image = "bash";
      failure = "ignore";
      commands = [
        "ls -lA" # TODO remove
        "test -L result-${name}"
      ];
    };

    checkMachineBuildStatus = name: {
      name = "check-${name}-status";
      image = "registry.gitlab.com/gitlab-ci-utils/curl-jq:latest";
      commands = [
        "test 'true' = $(curl -s https://build.lounge.rocks/api/repos/24/pipelines/$CI_PIPELINE_NUMBER | jq '.workflows[] | select(.name == \"build-all-${systemFor name}\") .children[] | select(.name == \"check-output-${name}\") .state == \"success\"')"
      ];
    };
  };

  when = {
    branch = {
      include = [ "**" ];
      exclude = [ "no-private-data" ];
    };
    event = [ "push" ];
  };

  toFile = workflow: pkgs.writeText "workflow.json" (builtins.toJSON workflow);

  machineWorkflows = builtins.listToAttrs (
    map (
      name:
      let
        system = systemFor name;
      in
      lib.nameValuePair "build-${name}" {
        labels = {
          backend = "docker";
          platform = platforms."${system}";
        };
        skip_clone = true;
        inherit when;
        depends_on = [
          "build-all-${system}"
        ];
        runs_on = [
          "success"
          "failure"
        ];
        steps = [
          (steps.checkMachineBuildStatus name)
        ];
      }

    ) machines
  );

  workflows =
    machineWorkflows
    // (lib.mapAttrs' (
      system: platform:
      lib.nameValuePair ".build-all-${system}" {
        labels = {
          backend = "local";
          platform = platform;
        };
        inherit when;
        depends_on = [ ];
        steps = [
          steps.decryptPrivateData
          steps.atticSetup
          (steps.buildAllMachinesFor system)
        ]
        ++ (map (name: (steps.checkMachineOutput name)) (machinesFor system));
      }
    ) platforms);
in
pkgs.writeShellScriptBin "update-pipelines" ''
  set -euo pipefail
  shopt -s dotglob

  # make sure .woodpecker folder exists
  mkdir -p .woodpecker

  # empty content of .woodpecker folder
  rm -rf .woodpecker/*
    
  # copy pipelines to .woodpecker folder
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: workflow: ''
      cat ${toFile workflow} | ${pkgs.yq}/bin/yq -y -w 9999 > .woodpecker/${name}.yaml
    '') workflows
  )}
''

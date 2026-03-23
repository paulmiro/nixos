# nix run .\#woodpecker-pipeline
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

  nix = "nix --show-trace";
  nix-fast-build = "nix-fast-build --no-nom --skip-cached --attic-cache lounge-rocks:nix-cache";

  steps = {
    nixFlakeCheck = {
      name = "Nix flake check";
      image = "bash";
      failure = "ignore";
      commands = [ "${nix} flake check --show-trace" ];
    };

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

    nixFastBuildChecks = system: {
      name = "Build all ${system} machines";
      image = "bash";
      failure = "ignore";
      commands = [
        "${nix-fast-build} --flake \".#checks.${system}\""
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

  nixosConfigurations = lib.filterAttrs (
    name: config: config.config.paul.ci.enable
  ) flake-self.nixosConfigurations;

  systemFor = config: config.config.nixpkgs.hostPlatform.system;

  toFile = pipeline: pkgs.writeText "pipeline.json" (builtins.toJSON pipeline);

  mkMachinePipeline =
    {
      name,
      config,
      dependsOn,
    }:
    {
      labels = {
        backend = "local";
        platform = platforms."${systemFor config}";
      };
      inherit when;
      depends_on = dependsOn;
      runs_on = [ "failure" ]; # individual builds are only needed when the combined build fails
      steps = [
        steps.decryptPrivateData
        steps.atticSetup
        {
          name = "Build ${name}";
          image = "bash";
          commands = [
            "${nix-fast-build} --flake '.#nixosConfigurations.${name}.config.system.build.toplevel' --out-link 'result-${name}'"
          ];
        }
        {
          name = "Show ${name} info";
          image = "bash";
          commands = [
            "${nix} path-info --closure-size -h $(readlink -f 'result-${name}')"
          ];
        }
        {
          name = "Push ${name} to Attic";
          image = "bash";
          commands = [ "attic push lounge-rocks:nix-cache 'result-${name}'" ];
        }
      ];
    };

  machinePipelines = builtins.listToAttrs (
    lib.foldlAttrs
      (
        acc: name: value:
        (
          let
            prev = lib.lists.last acc;
            system = systemFor value;
          in
          (if prev.initial then [ ] else acc)
          ++ [
            {
              initial = false;
              prevNames = prev.prevNames // {
                "${system}" = "build-${name}";
              };
              name = "build-${name}";
              value = mkMachinePipeline {
                config = value;
                inherit name;
                # we depend on the previous machine's pipeline to make sure we don't build shared packages twice
                dependsOn = [
                  prev.prevNames."${system}"
                ]
                ++ lib.optional (!prev.initial) "build-all-${system}";
              };
            }
          ]
        )
      )
      # initial accumulator
      [
        {
          initial = true;
          # the first host for each system should depend on the build-all step for that system
          prevNames = lib.mapAttrs (system: platform: "build-all-${system}") platforms;
        }
      ]
      nixosConfigurations
  );

  pipelines =
    machinePipelines
    // {
      # dot for alphabetical sorting
      ".nix-flake-check" = {
        labels = {
          backend = "local";
          platform = "linux/amd64";
        };
        inherit when;
        steps = [
          steps.decryptPrivateData
          steps.nixFlakeCheck
        ];
      };
    }
    // lib.mapAttrs' (
      system: platform:
      lib.nameValuePair "build-all-${system}" {
        labels = {
          backend = "local";
          platform = platform;
        };
        inherit when;
        depends_on = [ "nix-flake-check" ];
        steps = [
          steps.decryptPrivateData
          steps.atticSetup
          (steps.nixFastBuildChecks system)
        ];
      }
    ) platforms;
in
pkgs.writeShellScriptBin "woodpecker-pipeline" ''
  set -euo pipefail
  shopt -s dotglob

  # make sure .woodpecker folder exists
  mkdir -p .woodpecker

  # empty content of .woodpecker folder
  rm -rf .woodpecker/*
    
  # copy pipelines to .woodpecker folder
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: pipeline: ''
      cat ${toFile pipeline} | ${pkgs.yq}/bin/yq -y -w 9999 > .woodpecker/${name}.yaml
    '') pipelines
  )}
''

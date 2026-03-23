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
      failure = "ignore"; # don't abort all builds just because one machine failed a check
      commands = [
        # "${nix} flake check --show-trace"
        "echo 'skipping'"
      ];
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

    buildAllMachinesFor = system: {
      name = "Build all ${system} machines";
      image = "bash";
      commands = [
        # "${nix-fast-build} --flake \".#checks.${system}\""
        "echo 'skipping'"
      ];
    };

    buildMachine = name: {
      name = "Build ${name}";
      image = "bash";
      commands = [
        # "${nix-fast-build} --flake '.#nixosConfigurations.${name}.config.system.build.toplevel' --out-link 'result-${name}'"
        "echo 'skipping'"
      ];
    };

    showMachineInfo = name: {
      name = "Show ${name} info";
      image = "bash";
      commands = [
        # "${nix} path-info --closure-size -h $(readlink -f 'result-${name}-')" # trailing "-" in the link because nix-fast-build adds it
        "echo 'skipping'"
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

  toFile = pipeline: pkgs.writeText "pipeline.json" (builtins.toJSON pipeline);

  machinePipelines = builtins.listToAttrs (
    lib.foldlAttrs
      (
        acc: name: config:
        (
          let
            prev = lib.lists.last acc;
            system = config.config.nixpkgs.hostPlatform.system;
          in
          (if prev.initial then [ ] else acc)
          ++ [
            {
              initial = false;
              prevNames = prev.prevNames // {
                "${system}" = "build-${name}";
              };
              name = "build-${name}";
              value = {
                labels = {
                  backend = "local";
                  platform = platforms."${system}";
                };
                when = when // {
                  status = [ "failure" ];
                };
                depends_on = [
                  "build-all-${system}"
                ]
                ++ lib.optional (!prev.initial) prev.prevNames."${system}";
                runs_on = [ "failure" ]; # individual builds are only needed when the combined build fails
                steps = [
                  steps.decryptPrivateData
                  steps.atticSetup
                  (steps.buildMachine name)
                  (steps.showMachineInfo name)
                ];
              };
            }
          ]
        )
      )
      # initial accumulator
      [
        {
          initial = true;
          prevNames = { };
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
          (steps.buildAllMachinesFor system)
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

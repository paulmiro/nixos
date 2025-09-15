# nix run .\#woodpecker-pipeline
{
  flake-self,
  lib,
  pkgs,
  ...
}:
let
  platforms = {
    "aarch64-linux" = "linux/arm64";
    "x86_64-linux" = "linux/amd64";
  };
  forAllSystems = lib.genAttrs (builtins.attrNames platforms);
  # Map platform names between woodpecker and nix
  nix = "nix --show-trace";
  nixFlakeShow = {
    name = "Nix flake show";
    image = "bash";
    commands = [ "${nix} flake show" ];
  };
  decryptPrivateDataStep = {
    name = "Decrypt Private Data";
    image = "bash";
    commands = [
      "cd modules/private"
      "echo $AGE_KEY_PRIVATE_DATA | nix shell nixpkgs#age --command age --decrypt -i - -o private.toml.decrypted private.toml"
      "mv private.toml.decrypted private.toml"
    ];
    environment.AGE_KEY_PRIVATE_DATA.from_secret = "AGE_KEY_PRIVATE_DATA";
  };
  nixFlakeCheck = {
    name = "Nix flake check";
    image = "bash";
    commands = [ "${nix} flake check --show-trace" ];
  };
  atticSetupStep = {
    name = "Setup Attic";
    image = "bash";
    commands = [
      "attic login lounge-rocks https://cache.lounge.rocks $ATTIC_KEY --set-default"
    ];
    environment.ATTIC_KEY.from_secret = "attic_key";
  };
  pipelines = forAllSystems (
    system:
    pkgs.writeText "pipeline.json" (
      builtins.toJSON {
        labels = {
          backend = "local";
          platform = platforms."${system}";
        };
        steps = pkgs.lib.lists.flatten (
          [
            decryptPrivateDataStep
            nixFlakeShow
          ]
          ++ lib.optionals ("${system}" == "x86_64-linux") [ nixFlakeCheck ]
          ++ [ atticSetupStep ]
          ++ (map
            (host: [
              {
                name = "Build ${host}";
                image = "bash";
                commands = [
                  "${nix} build --print-out-paths '.#nixosConfigurations.${host}.config.system.build.toplevel' -o 'result-${host}'"
                ];
              }
              {
                name = "Show ${host} info";
                image = "bash";
                commands = [
                  "${nix} path-info --closure-size -h $(readlink -f 'result-${host}')"
                ];
              }
              {
                name = "Push ${host} to Attic";
                image = "bash";
                commands = [ "attic push lounge-rocks:nix-cache 'result-${host}'" ];
              }
            ])
            (
              builtins.attrNames (
                lib.filterAttrs (
                  name: config: config.config.nixpkgs.hostPlatform.system == system
                ) flake-self.nixosConfigurations
              )
            )
          )
        );
      }
    )
  );
in
pkgs.writeShellScriptBin "woodpecker-pipeline" ''
  # make sure .woodpecker folder exists
  mkdir -p .woodpecker

  # empty content of .woodpecker folder
  rm -rf .woodpecker/*
    
  # copy pipelines to .woodpecker folder
  cat ${pipelines.aarch64-linux} | ${pkgs.yq}/bin/yq -y -w 9999 > .woodpecker/arm64-linux.yaml
  cat ${pipelines.x86_64-linux} | ${pkgs.yq}/bin/yq -y -w 9999 > .woodpecker/x86-linux.yaml
''

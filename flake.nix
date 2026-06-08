{
  description = "My NixOS infrastructure";

  inputs = {
    ### Essentials

    # Nix Packages collection & NixOS
    # https://github.com/nixos/nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # A collection of NixOS modules covering hardware quirks.
    # https://github.com/NixOS/nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    ### Tools for managing NixOS infrastructure

    # Modular flake attributes
    # https://github.com/hercules-ci/flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    # Manage networks of machines
    # https://clan.lol
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";

    disko-zfs.url = "github:numtide/disko-zfs";
    disko-zfs.inputs.nixpkgs.follows = "nixpkgs";
    disko-zfs.inputs.flake-parts.follows = "flake-parts";
    disko-zfs.inputs.disko.follows = "clan-core/disko";

    # NixOS on the Windows Subsystem for Linux
    # https://github.com/nix-community/NixOS-WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS on the Android Virtualization Framework
    nixos-avf.url = "github:nix-community/nixos-avf";
    nixos-avf.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS on the Steam Deck, or for a SteamOS-like experience on other devices
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    jovian.inputs.nixpkgs.follows = "nixpkgs";

    # Work stuff, needs sops-nix, but that is included in clan
    betternix.url = "github:paulmiro/betternix";
    betternix.inputs.nixpkgs.follows = "nixpkgs";

    ### Packages outside of nixpkgs

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    grub2-themes.url = "github:paulmiro/grub2-themes";
    grub2-themes.inputs.nixpkgs.follows = "nixpkgs";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";

    nix4nvchad.url = "github:nix-community/nix4nvchad";
    nix4nvchad.inputs.nixpkgs.follows = "nixpkgs";

    git-agecrypt-armor.url = "github:paulmiro/git-agecrypt-armor";
    # git-agecrypt-armor.inputs.nixpkgs.follows = "nixpkgs";

    direnv-instant.url = "github:Mic92/direnv-instant";
    direnv-instant.inputs.nixpkgs.follows = "nixpkgs";

    useful-api.url = "github:paulmiro/useful-api";
    useful-api.inputs.nixpkgs.follows = "nixpkgs";

    friend-bet.url = "github:paulmiro/friend-bet";
    friend-bet.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    wrapper-modules.inputs.nixpkgs.follows = "nixpkgs";

    ### Non-Flake Inputs

    starship-no-empty-icons.url = "https://starship.rs/presets/toml/no-empty-icons.toml";
    starship-no-empty-icons.flake = false;
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        lib,
        self,
        withSystem,
        ...
      }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = [
          inputs.clan-core.flakeModules.default
          inputs.home-manager.flakeModules.home-manager
          inputs.pkgs-by-name-for-flake-parts.flakeModule
          (inputs.import-tree [
            ./home-manager
            ./modules
          ])
        ];

        clan = {
          meta.name = "paulmiro-clan";

          # we only pass the few inputs that are needed by machine configs directly
          specialArgs = {
            inherit (inputs)
              nixos-hardware
              nixos-wsl
              nixos-avf
              ;
          };

          inventory.instances = {
            importer-modules-dir = {
              module = {
                name = "importer";
                input = "clan-core";
              };
              roles.default.tags."all" = { };
              roles.default.extraModules = builtins.attrValues (
                lib.filterAttrs (n: _v: !lib.strings.hasPrefix "clan-machine-" n) self.nixosModules
              );
            };

            "borgbackup-turing" = {
              module = {
                name = "borgbackup";
                input = "clan-core";
              };
              roles.client.machines = {
                "backus" = { };
                "newton" = { };
              };

              roles.server.machines."turing".settings = {
                directory = "/mnt/borg";
              };
            };

            "borgbackup-backus" = {
              module = {
                name = "borgbackup";
                input = "clan-core";
              };
              roles.client.machines = {
                "turing" = { };
                "morse" = { };
              };

              roles.server.machines."backus".settings = {
                directory = "/mnt/borg";
              };
            };
          };

        };

        flake.overlays.default =
          final: prev:
          withSystem prev.stdenv.hostPlatform.system (
            { config, ... }:
            {
              paulmiro = config.packages;
            }
          );

        flake.homeConfigurations = lib.genAttrs config.systems (
          system:
          (lib.concatMapAttrs (
            profileName: profile:
            let
              configForUser =
                username:
                inputs.home-manager.lib.homeManagerConfiguration {
                  pkgs = inputs.nixpkgs.legacyPackages.${system};
                  extraSpecialArgs = {
                    # allow access to packags from external flakes without the ${pkgs.stdenv.hostPlatform.system} shenanigans
                    inputs' = (withSystem system ({ inputs', ... }: inputs'));
                  };
                  modules = [
                    profile
                    {
                      home.username = lib.mkDefault username;
                      home.homeDirectory = lib.mkDefault (if username == "root" then "/root" else "/home/${username}");
                    }
                  ];
                };
            in
            {
              "${profileName}" = configForUser "paulmiro";
              "${profileName}-root" = configForUser "root";
            }
          ) self.homeProfiles)
        );

        perSystem =
          {
            self',
            pkgs,
            lib,
            system,
            ...
          }:
          {
            formatter = pkgs.nixfmt-tree;

            pkgsDirectory = ./pkgs;

            checks =
              let
                ciHosts = lib.filterAttrs (_name: host: host.config.paul.ci.enable) self.nixosConfigurations;
                ciHostsForSystem = lib.filterAttrs (
                  _name: host: system == host.config.nixpkgs.hostPlatform.system
                ) ciHosts;
                toplevelsForSystem = builtins.mapAttrs (
                  _name: host: host.config.system.build.toplevel
                ) ciHostsForSystem;
              in
              toplevelsForSystem // { devShell = self'.devShells.default; };

            devShells.default = pkgs.mkShell {
              packages = [
                inputs.git-agecrypt-armor.packages.${system}.default
                inputs.clan-core.packages.${system}.clan-cli
                (pkgs.writeShellScriptBin "rebuild" ''
                  set -euo pipefail
                  hostname=''${1:-$(hostname)}
                  if [[ $hostname != $(hostname) ]]; then
                    echo "WARNING: Rebuilding configuration for \"$hostname\" on \"$(hostname)\""
                  fi
                  ${pkgs.nix-output-monitor}/bin/nom  build .#nixosConfigurations.$hostname.config.system.build.toplevel
                  ${pkgs.nixos-rebuild}/bin/nixos-rebuild --sudo switch --flake .#$hostname
                '')
                (pkgs.writeShellScriptBin "rollout" "${
                  inputs.clan-core.packages.${system}.clan-cli
                }/bin/clan machines update $@")
                self'.packages.create-nixos-module # mkmod
                self'.packages.create-home-manager-module # mkhmmod
                self'.packages.create-nix-package # mkpkg
                self'.packages.create-nix-package-script # mkscript
              ];
            };
          };
      }
    );
}

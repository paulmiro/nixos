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

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    ### Tools for managing NixOS infrastructure

    # Modular flake attributes
    # https://github.com/hercules-ci/flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # Manage networks of machines
    # https://clan.lol
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";

    # NixOS on the Windows Subsystem for Linux
    # https://github.com/nix-community/NixOS-WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # NixOS on the Android Virtualization Framework
    nixos-avf.url = "github:nix-community/nixos-avf";

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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    ### Non-Flake Inputs

    starship-no-empty-icons.url = "https://starship.rs/presets/toml/no-empty-icons.toml";
    starship-no-empty-icons.flake = false;
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        self,
        lib,
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
        ];

        clan = {
          meta.name = "paulmiro-clan";

          specialArgs = {
            flake-self = self;
          }
          // inputs;

          inventory.instances = {
            importer-modules-dir = {
              module = {
                name = "importer";
                input = "clan-core";
              };
              roles.default.tags."all" = { };
              # roles.default.extraModules = builtins.attrValues self.nixosModules; # TODO fix: this is broken but below works
              roles.default.extraModules = map (name: import (./modules + "/${name}")) (
                builtins.attrNames (builtins.readDir ./modules)
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

        flake.overlays.default = final: prev: {
          paulmiro = self.packages.${final.stdenv.hostPlatform.system};
        };

        flake.nixosModules = builtins.listToAttrs (
          map (name: {
            inherit name;
            value = import (./modules + "/${name}");
          }) (builtins.attrNames (builtins.readDir ./modules))
        );

        flake.homeConfigurations = lib.genAttrs self.systems (
          system:
          (lib.concatMapAttrs (
            profileName: profile:
            let
              configForUser =
                username:
                inputs.home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages.${system};
                  modules = [
                    profile
                    {
                      home.username = lib.mkDefault username;
                      home.homeDirectory = lib.mkDefault (if username == "root" then "/root" else "/home/${username}");
                    }
                  ];
                  extraSpecialArgs = {
                    flake-self = self;
                  }
                  // inputs;
                };
            in
            {
              "${profileName}" = configForUser "paulmiro";
              "${profileName}-root" = configForUser "root";
            }
          ) self.homeProfiles)
        );

        flake.homeProfiles = builtins.listToAttrs (
          map (filename: {
            name = builtins.substring 0 ((builtins.stringLength filename) - 4) filename;
            value = {
              imports = [
                ./home-manager/profiles/common.nix
                (./home-manager/profiles + "/${filename}")
              ]
              ++ (builtins.attrValues self.homeModules);
            };
          }) (builtins.attrNames (builtins.readDir ./home-manager/profiles))
        );

        flake.homeModules =
          builtins.listToAttrs (
            map (name: {
              inherit name;
              value = import (./home-manager/modules + "/${name}");
            }) (builtins.attrNames (builtins.readDir ./home-manager/modules))
          )
          // {
            private = import ./modules/private;
          };

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

            packages = (
              builtins.listToAttrs (
                map (name: {
                  inherit name;
                  value = pkgs.callPackage (./pkgs + "/${name}") { flake-self = self; };
                }) (builtins.attrNames (builtins.readDir ./pkgs))
              )
            );

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
              toplevelsForSystem;

            devShells.default = pkgs.mkShell {
              packages = [
                inputs.git-agecrypt-armor.packages.${system}.default
                inputs.clan-core.packages.${system}.clan-cli
                (pkgs.writeShellScriptBin "rebuild" "${pkgs.nixos-rebuild}/bin/nixos-rebuild --sudo switch --flake . $@")
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

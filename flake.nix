{
  description = "My NixOS infrastructure";

  inputs = {

    ### Essential inputs

    # Nix Packages collection & NixOS
    # https://github.com/nixos/nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # A collection of NixOS modules covering hardware quirks.
    # https://github.com/NixOS/nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Tools for managing NixOS infrastructure

    # Manage networks of machines
    # https://clan.lol
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      # Don't do this if your machines are on nixpkgs stable.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS on the Windows Subsystem for Linux
    # https://github.com/nix-community/NixOS-WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # NixOS on the Android Virtualization Framework
    nixos-avf.url = "github:nix-community/nixos-avf";

    ### Packages outside of nixpkgs

    authentik-nix = {
      url = "github:nix-community/authentik-nix";

      ## optional overrides. Note that using a different version of nixpkgs can cause issues, especially with python dependencies
      # inputs.nixpkgs.follows = "nixpkgs"
      # inputs.flake-parts.follows = "flake-parts"
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      #url = "git+file:///home/paulmiro/repos/paulmiro/grub2-themes";
      url = "github:paulmiro/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-agecrypt-armor = {
      url = "github:paulmiro/git-agecrypt-armor";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Non-Flake Inputs

    immich-source = {
      flake = false;
      url = "github:immich-app/immich";
    };

  };

  outputs =
    { self, ... }@inputs:
    with inputs;
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );

      flakePkgs =
        pkgs:
        (builtins.listToAttrs (
          map (name: {
            inherit name;
            value = pkgs.callPackage (./pkgs + "/${name}") { flake-self = self; };
          }) (builtins.attrNames (builtins.readDir ./pkgs))
        ));

      clan = clan-core.lib.clan {
        inherit self; # this needs to point at the repository root

        # Make inputs and the flake itself accessible as module parameters.
        # Technically, adding the inputs is redundant as they can be also
        # accessed with flake-self.inputs.X, but adding them individually
        # allows to only pass what is needed to each module.
        specialArgs = {
          flake-self = self;
        }
        // inputs;

        inventory = {

          meta.name = "paulmiro-clan";

          instances = {
            importer-modules-dir = {
              module = {
                name = "importer";
                input = "clan-core";
              };
              roles.default.tags."all" = { };
              # import all modules from ./modules/<module-name> everywhere
              roles.default.extraModules = (map (m: "modules/${m}") (builtins.attrNames self.nixosModules));
            };
          };

        };

      };
    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-tree);

      packages = forAllSystems (system: flakePkgs nixpkgsFor.${system});

      overlays = {
        paulmiro-overlay = final: prev: {
          paulmiro = flakePkgs prev;
        };
      };

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (./modules + "/${name}");
        }) (builtins.attrNames (builtins.readDir ./modules))
      );

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first

      inherit (clan.config) nixosConfigurations clanInternals;
      clan = clan.config;

      homeConfigurations = builtins.listToAttrs (
        map (filename: {
          name = builtins.substring 0 ((builtins.stringLength filename) - 4) filename;
          value =
            {
              ...
            }:
            {
              imports = [
                "${./.}/home-manager/profiles/common.nix"
                "${./.}/home-manager/profiles/${filename}"
              ]
              ++ (builtins.attrValues self.homeManagerModules);
            };
        }) (builtins.attrNames (builtins.readDir ./home-manager/profiles))
      );

      homeManagerModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (./home-manager/modules + "/${name}");
        }) (builtins.attrNames (builtins.readDir ./home-manager/modules))
      );

      devShells = forAllSystems (
        system: with nixpkgsFor.${system}; {
          default = pkgs.mkShell {
            packages = [
              git-agecrypt-armor.packages.${system}.default
              clan-core.packages.${system}.clan-cli
              (pkgs.writeShellScriptBin "rebuild" "${pkgs.nixos-rebuild}/bin/nixos-rebuild --sudo switch --flake .")
              (pkgs.writeShellScriptBin "rollout" "${
                clan-core.packages.${system}.clan-cli
              }/bin/clan machines update $@")
            ];
          };
        }
      );

    };
}

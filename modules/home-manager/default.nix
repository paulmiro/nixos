{
  config,
  flake-self,
  home-manager,
  lib,
  ...
}:
let
  cfg = config.paul.home-manager;
  profileType = lib.types.enum (builtins.attrNames flake-self.homeConfigurations);
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.paul.home-manager = {
    enable = lib.mkEnableOption "enable home-manager";

    profile = lib.mkOption {
      description = "which home-mamager profile to use for user paulmiro";
      type = profileType;
      default = "common";
    };

    rootProfile = lib.mkOption {
      description = "which home-manager profile to use for user root";
      type = profileType;
      default = "common";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      # DON'T set useGlobalPackages! It's not necessary in newer
      # home-manager versions and does not work with configs using
      # nixpkgs.config`
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {
        # Pass all flake inputs to home-manager modules aswell so we can use them there.
        inherit flake-self;
        # Pass system configuration (top-level "config") to home-manager modules,
        # so we can access it's values for conditional statements
        system-config = config;
      } // flake-self.inputs;
      users.paulmiro = flake-self.homeConfigurations.${cfg.profile};
      users.root = flake-self.homeConfigurations.${cfg.rootProfile};
    };
  };
}

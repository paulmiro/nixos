{
  config,
  flake-self,
  home-manager,
  lib,
  ...
}:
let
  cfg = config.paul.home-manager;
  profileType = lib.types.enum (builtins.attrNames flake-self.homeProfiles);
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.paul.hm = lib.mkOption {
    description = "Config to pass to home-manager.users.paulmiro.config.paul";
    type = lib.types.attrs;
    default = { };
  };

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
      }
      // flake-self.inputs;
      users.paulmiro = lib.mkMerge [
        flake-self.homeProfiles.${cfg.profile}
        {
          imports = [ { config.paul = config.paul.hm; } ];
        }
      ];
      users.root = flake-self.homeProfiles.${cfg.rootProfile};
    };
  };
}

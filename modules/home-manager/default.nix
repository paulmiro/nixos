{
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.nixosModules.home-manager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.paul.home-manager;
      profileType = lib.types.enum (builtins.attrNames self.homeProfiles);
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "paulmiro" ])
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
            # allow access to packags from external flakes without the ${pkgs.stdenv.hostPlatform.system} shenanigans
            inputs' = (withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs'));
          };
          users.paulmiro = self.homeProfiles.${cfg.profile};
          users.root = self.homeProfiles.${cfg.rootProfile};
        };
      };
    };
}

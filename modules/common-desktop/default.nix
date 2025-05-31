{
  config,
  flake-self,
  home-manager,
  lib,
  ...
}:
let
  cfg = config.paul.common-desktop;
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.paul.common-desktop = {
    enable = lib.mkEnableOption "contains configuration that is common to all systems with a desktop environment";
  };

  config = lib.mkIf cfg.enable {
    paul = {
      common.enable = true;
      sound.enable = true;
      fonts.enable = true;
      locale.hardwareClockInLocalTime = true;
    };

    home-manager = {
      # DON'T set useGlobalPackages! It's not necessary in newer
      # home-manager versions and does not work with configs using
      # nixpkgs.config`
      useUserPackages = true;
      extraSpecialArgs = {
        # Pass all flake inputs to home-manager modules aswell so we can use them
        # there.
        inherit flake-self;
        # Pass system configuration (top-level "config") to home-manager modules,
        # so we can access it's values for conditional statements
        system-config = config;
      };
      users.paulmiro = flake-self.homeConfigurations.desktop;
      users.root = flake-self.homeConfigurations.server;
    };
  };
}

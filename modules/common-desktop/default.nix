{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.common-desktop;
in
{
  options.paul.common-desktop = {
    enable = lib.mkEnableOption "contains configuration that is common to all systems with a desktop environment";
  };

  config = lib.mkIf cfg.enable {
    paul = {
      common.enable = true;
      home-manager.profile = lib.mkDefault "desktop";

      sound.enable = true;
      fonts.enable = true;
      tailscale.routingFeatures = "client";
    };

    time.hardwareClockInLocalTime = lib.mkDefault true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    zramSwap.enable = true;
  };
}

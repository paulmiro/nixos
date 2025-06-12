{
  config,
  lib,
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
      sound.enable = true;
      fonts.enable = true;
      locale.hardwareClockInLocalTime = true;

      home-manager.profile = "desktop";
    };
  };
}

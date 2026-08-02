{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.dev;
  enable = cfg.android || cfg.adb;
in
{
  options.paul.dev.android = lib.mkEnableOption "enable android";
  options.paul.dev.adb = lib.mkEnableOption "enable adb";

  config = lib.mkIf enable {
    home.sessionVariables = {
      ANDROID_HOME = "~/.android/sdk"; # because fuck whoever decided to name that folder "Android" instead of ".android"
    };

    home.packages =
      (lib.optional cfg.adb pkgs.android-tools) ++ (lib.optional cfg.android pkgs.android-studio);
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = config.paul.dev.android;
in
{
  options.paul.dev.android = lib.mkEnableOption "enable android";
  options.paul.dev.adb = lib.mkEnableOption "enable adb";

  config = lib.mkIf enable {
    home.sessionVariables = {
      ANDROID_HOME = "~/.android/sdk"; # because fuck whoever decided to name that folder "Android" instead of ".android"
    };

    home.packages =
      with pkgs;
      [
        android-tools
      ]
      ++ lib.optional cfg.android android-studio;
  };
}

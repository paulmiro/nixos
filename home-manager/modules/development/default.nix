{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.development;
in
{
  options.paul.programs.development.enable =
    mkEnableOption "enable development applications";

  config = mkIf cfg.enable {

    ## Go
    programs.go = {
      enable = true;
      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.go.packages
      packages = { };
    };

    home.sessionVariables = {
      ANDROID_HOME = "~/.android/sdk"; # because fuck whoever decided to name that folder "Android" instead of ".android"
    };

    home.packages = with pkgs; [
      ## Android
      android-studio
      android-tools

      ## C/C++
      clang
      cmake

      ## Java
      jdk21

      ## JavaScript
      bun
      nodejs
      nodePackages.pnpm
      nodePackages.eas-cli

      ## Lua
      lua
      stylua

      ## Python
      (python3.withPackages (ps: with ps; [
        requests
        numpy
        jupyter
      ]))

    ];

  };
}

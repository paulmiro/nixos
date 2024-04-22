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
      nodejs_21
      nodePackages.pnpm

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

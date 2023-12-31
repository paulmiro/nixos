{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.development;
in
{
  options.paul.programs.development.enable =
    mkEnableOption "enable development applications";

  config = mkIf cfg.enable {

    programs.go = {
      enable = true;
      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.go.packages
      packages = { };
    };

    home.packages = with pkgs; [

      ### Programming languages / compiler
      bun
      # cargo
      clang
      lua
      # rustc
      # gcc
      (python3.withPackages (ps: with ps; [
        requests
        numpy
        jupyter
      ]))

      ### Formatter
      # nixfmt
      # nixpkgs-fmt
      # rustfmt
      stylua

    ];

  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.rbw;
in
{
  options.paul.programs.rbw.enable = mkEnableOption "enable rbw, an alternative to bitwaren-cli";

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = builtins.readFile ../../../secrets/rbw-email; # TODO: make this realative to flake-self instead of this folder
        pinentry = pkgs.pinentry-tty;
      };
    };
  };
}

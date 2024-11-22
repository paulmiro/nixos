{ lib, pkgs, config, system-config, ... }:
with lib;
let cfg = config.paul.programs.rbw;
in
{
  options.paul.programs.rbw.enable = mkEnableOption "enable rbw, an alternative to bitwaren-cli";

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = system-config.paul.private.emails.gmail;
        pinentry = pkgs.pinentry-tty;
      };
    };
  };
}

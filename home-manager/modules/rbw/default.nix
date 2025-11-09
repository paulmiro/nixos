{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.rbw;
in
{
  options.paul.programs.rbw.enable = lib.mkEnableOption "enable rbw, an alternative to bitwaren-cli";

  config = lib.mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = config.paul.private.emails.gmail;
        pinentry = pkgs.pinentry-tty;
      };
    };
  };
}

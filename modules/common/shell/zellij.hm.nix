{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.zellij;
in
{
  options.paul.zellij = {
    enable = lib.mkEnableOption "enable zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        default_mode = "locked"; # ctrl-g to unlock
        show_startup_tips = false;
      };
    };
  };
}

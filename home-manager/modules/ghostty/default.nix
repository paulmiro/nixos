{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.ghostty;
in
{
  options.paul.ghostty = {
    enable = lib.mkEnableOption "enable ghostty";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ghostty ];
    xdg.configFile."ghostty/config".source = ./config;
  };
}

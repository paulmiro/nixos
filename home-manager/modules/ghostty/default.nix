{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.ghostty;
in
{
  options.paul.programs.ghostty = {
    enable = lib.mkEnableOption "enable ghostty";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ghostty ];
    xdg.configFile."ghostty/config".source = ./config;
  };
}

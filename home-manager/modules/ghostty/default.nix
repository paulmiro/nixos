{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.programs.ghostty; in
{
  options.paul.programs.ghostty = {
    enable = mkEnableOption "enable ghostty";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;[ ghostty ];
    xdg.configFile."ghostty/config".source = ./config;
  };
}

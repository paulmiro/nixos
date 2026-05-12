{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.niri-settings;
in
{
  options.paul.niri-settings = {
    enable = lib.mkEnableOption "enable niri-settings";
  };

  config = lib.mkIf cfg.enable {
    
  };
}

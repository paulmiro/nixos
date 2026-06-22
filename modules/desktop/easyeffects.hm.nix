{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.easyeffects;
in
{
  options.paul.easyeffects = {
    enable = lib.mkEnableOption "activate easyeffects";
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
      extraPresets = {
        # no-op presets because the gnome extension expects there to be at least one per type
        default-in.input = {
          blocklist = [ ];
          plugins_order = [ ];
        };
        default-out.output = {
          blocklist = [ ];
          plugins_order = [ ];
        };
      };
    };

    paul.gnome-settings.enabledExtensions = [
      pkgs.gnomeExtensions.easyeffects-preset-selector
    ];
  };
}

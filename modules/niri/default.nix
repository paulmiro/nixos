{
  config,
  lib,
  pkgs,
  quickshell,
  ...
}:
let
  cfg = config.paul.niri;
in
{
  options.paul.niri = {
    enable = lib.mkEnableOption "enable niri";
  };

  config = lib.mkIf cfg.enable {
    paul.hm.niri-settings.enable = true;

    programs.dms-shell = {
      enable = true;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableClipboardPaste = true; # Pasting from the clipboard history (wtype)

      quickshell.package = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };

    security.polkit.enable = true; # polkit
    services.gnome.gnome-keyring.enable = true; # secret service

    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };

    programs.niri = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite # xwayland support
    ];

  };
}

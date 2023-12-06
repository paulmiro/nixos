{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.gnome-settings;
in
{
  options.paul.programs.gnome-settings.enable =
    mkEnableOption "enamble custom gnome configuration and theme";
  
  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.clipboard-indicator
      # gnomeExtensions.gesture-improvements # not yet compatible with gnome 45
      gnomeExtensions.gsconnect
      gnomeExtensions.just-perfection
      gnomeExtensions.vitals
      gnomeExtensions.wifi-qrcode
      gnomeExtensions.window-gestures
    ];

    gtk = {
      enable = true;
      theme = {
        name = "Orchis-Grey-Dark";
        package = (pkgs.orchis-theme).override {
          border-radius = 5;
        };
      };
      iconTheme = {
        name = "Tela-orange-dark";
        package = pkgs.tela-icon-theme;
      };

      cursorTheme = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

    };

    /*
    home.sessionVariables = {
      GTK_THEME = "Orchis-Grey-Dark";
      };
    */
    
    # Use `dconf watch /` to track stateful changes you are doing, then set them here.
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        monospace-font-name = "MesloLGS NF 10";
        gtk-enable-primary-paste = false;
        clock-show-weekday = true;
        clock-show-date = true;
        clock-show-seconds = false;
        enable-hot-corners = false;
        show-battery-percentage = true;

      };
      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = true;
      };
      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "lower";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        touch-to-click = true;
      };
      "org/gnome/desktop/search-providers" = {
        disabled = [ "org.gnome.Epiphany.desktop" "org.gnome.Contacts.desktop" ];
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
        workspaces-only-on-primary = true;
      };
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = false;
      };
      "org/gnome/system/location" = {
        enabled = true;
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };

      # Extension Settings
      "org/gnome/shell/extensions/vitals" = { };
      "org/gnome/shell/extensions/blur-my-shell" = {
        sigma = 50;
        brightness = 0.7;
        noise-amout = 0.8;
        noise-lightness = 1.2;
        color-and-noise = true;
      };

    };
  };
}


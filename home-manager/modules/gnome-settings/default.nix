{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.gnome-settings;
in
{
  options.paul.programs.gnome-settings.enable =
    mkEnableOption "enamble custom gnome configuration and theme";

  config = mkIf cfg.enable {

    gtk = {
      enable = true;

      /*
      theme = {
        name = "Fluent-round-orange-Dark-compact";
        package = (pkgs.fluent-gtk-theme.override {
          themeVariants = [ "all" ];
          colorVariants = [ "standard" "light" "dark" ];
          sizeVariants = [ "standard" "compact" ];
          tweaks = [ "round" "noborder" ];
        });
      };
      */
      theme = {
        name = "Orchis-Orange-Dark-Compact";
        package = (pkgs.orchis-theme).override {
          border-radius = 5;
          tweaks = [ "compact" ];
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

    home.sessionVariables = {
      /*
      GTK_THEME = "Fluent-round-orange-Dark-compact";
      */
      GTK_THEME = "Orchis-Orange-Dark-Compact";
    };

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
    };
  };
}


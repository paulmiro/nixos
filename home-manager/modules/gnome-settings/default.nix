{ lib, pkgs, config, system-config, ... }:
with lib;
let cfg = config.paul.programs.gnome-settings;
in
{
  options.paul.programs.gnome-settings.enable =
    mkEnableOption "enamble custom gnome configuration and theme";

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      gnomeExtensions.activate_gnome
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.clipboard-indicator
      # gnomeExtensions.gesture-improvements # not yet compatible with gnome 45
      gnomeExtensions.gsconnect
      gnomeExtensions.just-perfection
      gnomeExtensions.tailscale-qs
      gnomeExtensions.vitals
      gnomeExtensions.wifi-qrcode
      gnomeExtensions.window-gestures
    ];

    gtk = {
      enable = true;
      /*
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
      */
      cursorTheme = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
      };
    };

    # Use `dconf watch /` to track stateful changes you are doing, then set them here.
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [ "zen.desktop" "code.desktop" "org.gnome.Console.desktop" "org.gnome.Nautilus.desktop" ];
        # TODO: enable all extensions and nixify their settings
        enabled-extensions = [ "blur-my-shell@aunetx" "clipboard-indicator@tudmotu.com" "burn-my-windows@schneegans.github.com" "gsconnect@andyholmes.github.io" "drive-menu@gnome-shell-extensions.gcampax.github.com" "wifiqrcode@glerro.pm.me" "windowgestures@extension.amarullz.com" "tailscale@joaophi.github.com" ];
      };

      "org/gnome/desktop/interface" = {
        accent-color = "yellow";
        gtk-enable-primary-paste = false;
        monospace-font-name = mkIf system-config.paul.fonts.enable "MesloLGS NF 10";
        show-battery-percentage = true;
        enable-hot-corners = false;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
      };

      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
        workspaces-only-on-primary = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "lower";
        resize-with-right-button = true;
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = false;
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file://${./wallpapers/dino-falin.jpg}";
        picture-uri-dark = "file://${./wallpapers/dino-falin.jpg}";
      };

      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${./wallpapers/dino-falin.jpg}";
      };

      "org/gnome/desktop/session" = {
        idle-delay = lib.gvariant.mkUint32 300;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout = 7200;
        sleep-inactive-battery-timeout = 1800;
      };

      "org/gnome/desktop/input-sources" = {
        sources = [ (lib.gvariant.mkTuple [ "xkb" "us" ]) (lib.gvariant.mkTuple [ "xkb" "de" ]) ];
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
      };
    };
  };
}


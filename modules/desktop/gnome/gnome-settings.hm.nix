{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.gnome-settings;
  version = lib.versions.major pkgs.gnome-shell.version;
in
{
  # auto-enabled by nixos module
  options.paul.gnome-settings = {
    enable = lib.mkEnableOption "enable custom gnome configuration and theme";
    wallpaper = lib.mkOption {
      type = lib.types.str;
      default = "dino-falin.jpg";
      description = "wallpaper to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        # some plugins take ages to update to the latest GNOME version,
        # but most of the time they don't actually need any code changes.
        # this function simply patches the metadata file to allow running
        # the plugin the current GNOME version.
        # this will probably break stuff in the future, but it seems to work fine for now.
        patchVersion =
          package:
          package.overrideAttrs (_: {
            patchPhase = ''
              ${pkgs.jq}/bin/jq 'if any(."shell-version"[]; . == "${version}") then . else ."shell-version" += ["${version}"] end' metadata.json > metadata.tmp.json
              mv metadata.tmp.json metadata.json 
            '';
          });
      in
      with pkgs.gnomeExtensions;
      [
        activate_gnome
        blur-my-shell
        burn-my-windows
        caffeine
        clipboard-indicator
        gsconnect
        just-perfection
        tailscale-qs
        touchpad-gesture-customization
        vitals
        wifi-qrcode

        # TODO maybe add these later
        # paperwm
        # workspace-matrix
      ]
      ++ map patchVersion [ ];

    gtk = {
      enable = true;
      gtk4.theme = null;
      cursorTheme = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
      };
    };

    # Use `dconf watch /` to track stateful changes you are doing, then set them here.
    # Or use `dconf dump / | dconf2nix` to convert the current settings to nix code
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "zen.desktop"
          "code.desktop"
          "com.mitchellh.ghostty.desktop"
          "org.gnome.Nautilus.desktop"
        ];
        enabled-extensions = [
          "blur-my-shell@aunetx"
          "burn-my-windows@schneegans.github.com"
          "caffeine@patapon.info"
          "clipboard-indicator@tudmotu.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "gsconnect@andyholmes.github.io"
          "just-perfection-desktop@just-perfection"
          "status-icons@gnome-shell-extensions.gcampax.github.com"
          "tailscale-gnome-qs@tailscale-qs.github.io"
          "touchpad-gesture-customization@coooolapps.com"
          "Vitals@CoreCoding.com"
          "wifiqrcode@glerro.pm.me"
        ];
      };

      "org/gnome/desktop/interface" = {
        accent-color = "yellow";
        gtk-enable-primary-paste = false;
        monospace-font-name = "MesloLGS NF 10";
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
        picture-uri = "file://${./wallpapers/${cfg.wallpaper}}";
        picture-uri-dark = "file://${./wallpapers/${cfg.wallpaper}}";
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
        sources = [
          (lib.gvariant.mkTuple [
            "xkb"
            "de"
          ])
          (lib.gvariant.mkTuple [
            "xkb"
            "us"
          ])
        ];
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
      };

      # keybindings
      "org/gnome/shell/keybindings" = {
        toggle-message-tray = [ "<Super>w" ]; # defaults to <Super>v, but i need that for the clipboard-indicator
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "LinkedIn";
        binding = "<Shift><Control><Alt><Super>l";
        command = "zen https://linkedin.com";
      };

      # extension settings

      "org/gnome/shell/extensions/burn-my-windows" = {
        active-profile = "${./burn-my-windows-config.conf}";
      };

      "org/gnome/shell/extensions/caffeine" = {
        duration-timer-list = [
          900 # 15m
          3600 # 1h
          10800 # 3h
        ];
      };

      "org/gnome/shell/extensions/clipboard-indicator" = {
        move-item-first = true;
        clear-on-boot = true;
        confirm-clear = false;
        enable-keybindings = true;
        # this seems to be the only way to disable the keybindings individually
        private-mode-binding = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        toggle-menu = [ "<Super>v" ];
        clear-history = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        next-entry = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        prev-entry = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        workspace-wrap-around = true;
        workspace-switcher-should-show = true;
        window-demands-attention-focus = true;
        switcher-popup-delay = false;
        startup-status = 0;
        search = false;
        window-preview-caption = false;
        world-clock = false;
        workspace-switcher-size = 10;
        animation = 5;
      };

      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_processor_usage_"
          "_memory_usage_"
          "__temperature_max__"
        ];
        show-temperature = true;
        show-voltage = false;
        show-fan = false;
        show-memory = true;
        show-processor = true;
        show-system = false;
        show-network = false;
        show-storage = false;
        show-battery = false;
        show-gpu = false;
        position-in-panel = 0;
      };

      "org/gnome/shell/extensions/touchpad-gesture-customization" = {
        horizontal-swipe-3-fingers-gesture = "NONE";
        horizontal-swipe-4-fingers-gesture = "WORKSPACE_SWITCHING";
        pinch-3-finger-gesture = "NONE";
        pinch-4-finger-gesture = "NONE";
        vertical-swipe-3-fingers-gesture = "WINDOW_MANIPULATION";
        vertical-swipe-4-fingers-gesture = "OVERVIEW_NAVIGATION";
        enable-forward-back-gesture = true;
      };

      # app settings

      "org/gnome/Console" = {
        font-scale = 1.4;
      };

      "org/gnome/tweaks" = {
        show-extensions-notice = false; # annoying popup
      };

      "org/gnome/desktop/notifications/application/spotify" = {
        enable = false; # to prevent the current song showing up twice in the panel
      };
    };
  };
}

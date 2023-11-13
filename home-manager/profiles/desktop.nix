{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
      programs.direnv.enable = true;
      programs.development.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      discord
      firefox
      gparted
      jellyfin-mpv-shim
      libreoffice
      krita
      mpv
      obsidian
      protonmail-bridge
      prusa-slicer
      signal-desktop
      spot
      thunderbird-bin
      element-desktop
      whatsapp-for-linux
      xournalpp
      zoom-us

      oneko

      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection
    ];

    gtk = {
      enable = true;

      theme = {
        name = "Fluent-round-purple-Dark-compact";
        package = (pkgs.fluent-gtk-theme.override {
          themeVariants = [ "all" ];
          colorVariants = [ "standard" "light" "dark" ];
          sizeVariants = [ "standard" "compact" ];
          tweaks = [ "round" "noborder" ];
        });
      };

      iconTheme = {
        name = "Fluent";
        package = pkgs.fluent-icon-theme;
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
      GTK_THEME = "Fluent-round-purple-Dark-compact";
    };
  };
}

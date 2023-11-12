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

      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection
    ];

    gtk = {
      enable = true;

      # cursorTheme = {
      #   name = "capitaine-cursors";
      #   package = pkgs.capitaine-cursors;
      # };

      cursorTheme = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
      };
    };
  };
}

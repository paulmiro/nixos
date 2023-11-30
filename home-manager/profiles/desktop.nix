{ pkgs, lib, config, ... }:
with lib;
{
  config = {
    paul = {
      programs.vscode.enable = true;
      programs.direnv.enable = true;
      programs.development.enable = true;
      programs.gnome-settings.enable = true;
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
      obs-studio
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
      sl
      burpsuite
      oneko

      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection
      gnomeExtensions.gsconnect
      gnomeExtensions.clipboard-history
    ];
  };
}

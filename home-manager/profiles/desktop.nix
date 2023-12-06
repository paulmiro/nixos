{ pkgs, lib, config, ... }:
with lib;
{
  config = {
    paul = {
      programs.development.enable = true;
      programs.direnv.enable = true;
      programs.gnome-settings.enable = true;
      programs.vscode.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      burpsuite
      discord
      element-desktop
      firefox
      gparted
      jellyfin-mpv-shim
      krita
      libreoffice
      mpv
      obs-studio
      obsidian
      oneko
      protonmail-bridge
      prusa-slicer
      signal-desktop
      sl
      spot
      thunderbird-bin
      whatsapp-for-linux
      xournalpp
      zoom-us
    ];
  };
}

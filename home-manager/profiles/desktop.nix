{ pkgs, lib, config, system-config, ... }:
with lib;
{
  config = {
    paul = {
      programs.development.enable = true;
      programs.direnv.enable = true;
      programs.gnome-settings.enable = true;
      programs.vscode.enable = true;
    };

    nixpkgs.config.permittedInsecurePackages = [
      "electron-25.9.0" # Temporary fix for Obsidian
    ];

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
      spotify
      thunderbird-bin
      tor-browser
      whatsapp-for-linux
      xournalpp
      zoom-us
    ]
    # only install these packages on x86_64-linux systems
    ++ lib.optionals (system-config.nixpkgs.hostPlatform.isx86_64) [
      nvtop
    ];
  };
}

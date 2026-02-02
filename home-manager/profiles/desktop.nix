{
  pkgs,
  ...
}:
{
  config = {
    paul = {
      gnome-settings.enable = true;
      vscode.enable = true;
      ghostty.enable = true;
      neovim.enableNeovide = true;
      protonmail-bridge.enable = true;

      development = {
        android = true;
        go = true;
        javascript = true;
      };

      browsers = {
        chromium = true;
        tor = true;
        zen = true;
      };
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      anki-bin
      audacity
      cockatrice
      discord
      element-desktop
      # freecad # broken as of 2026-01-20
      gnome-graphs
      gparted
      inkscape
      jellyfin-mpv-shim
      # keyguard # broken as of 2026-01-25
      krita
      libreoffice
      mattermost-desktop
      mixxx
      mpv
      obs-studio
      obsidian
      oneko
      onlyoffice-desktopeditors
      pomodoro-gtk
      prusa-slicer
      orca-slicer
      qrtool
      rnote
      signal-desktop
      sl
      spotify
      switcheroo
      textpieces
      thunderbird-bin
      wasistlos
      xournalpp
      zoom-us

      paulmiro.nato
      paulmiro.vibe
    ];
  };
}

{
  pkgs,
  ...
}:
{
  config = {
    paul = {
      vscode.enable = true;
      ghostty.enable = true;
      neovim.enableNeovide = true;
      protonmail-bridge.enable = true;
      easyeffects.enable = true;

      dev = {
        go = true;
        godot = true;
        rust = true;
        adb = true;
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
      freecad
      gnome-graphs
      gnome-solanum # pomodoro timer
      gparted
      inkscape
      jellyfin-mpv-shim
      karere # whatsapp client
      keyguard
      krita
      libreoffice
      mattermost-desktop
      mixxx
      mpv
      obs-studio
      obsidian
      oneko
      onlyoffice-desktopeditors
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
      xournalpp
      zoom-us

      paulmiro.nato
    ];
  };
}

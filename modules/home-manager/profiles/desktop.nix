{
  pkgs,
  ...
}:
{
  config = {
    paul = {
      vscode.enable = true;
      ghostty.enable = true;
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
      audacity
      discord
      element-desktop
      freecad
      gnome-solanum # pomodoro timer
      gparted
      inkscape
      karere # whatsapp client
      krita
      libreoffice
      mixxx
      mpv
      obs-studio
      obsidian
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
      zoom-us

      paulmiro.nato
    ];
  };
}

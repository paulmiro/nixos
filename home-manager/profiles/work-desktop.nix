{
  pkgs,
  ...
}:
{
  config = {
    paul = {
      work.enable = true;

      gnome-settings.enable = true;
      vscode.enable = true;
      ghostty.enable = true;

      browsers = {
        chromium = true;
        zen = true;
      };
    };

    xdg.autostart = {
      enable = true;
      entries = with pkgs; [
        "${discord.desktopItem}/share/applications/discord.desktop"
        "${thunderbird-bin.desktopItem}/share/applications/thunderbird.desktop"
      ];
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      discord
      element-desktop
      gparted
      krita
      obs-studio
      obsidian
      oneko
      onlyoffice-desktopeditors
      pomodoro-gtk
      qrtool
      signal-desktop
      sl
      spotify
      switcheroo
      textpieces
      thunderbird-bin
      wasistlos

      paulmiro.nato
      paulmiro.vibe
    ];
  };
}

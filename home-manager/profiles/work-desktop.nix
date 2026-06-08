{ self, ... }:
{
  flake.homeProfiles.work-desktop =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeProfiles.common
      ];

      config = {
        paul = {
          work.enable = true;

          vscode.enable = true;
          ghostty.enable = true;

          gnome-settings.wallpaper = "dino-frieren.jpg";

          browsers = {
            chromium = true;
            firefox = true;
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
          bruno
          discord
          element-desktop
          gparted
          karere # whatsapp client
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

          paulmiro.nato
        ];
      };
    };
}

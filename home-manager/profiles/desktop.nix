{ self, ... }:
{
  flake.homeProfiles.desktop =
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
          vscode.enable = true;
          ghostty.enable = true;
          neovim.enableNeovide = true;
          protonmail-bridge.enable = true;

          development = {
            android = true;
            go = true;
            godot = true;
            javascript = true;
            rust = true;
          };

          browsers = {
            chromium = true;
            tor = true;
            zen = true;
          };
        };

        services.easyeffects.enable = true;

        # Install these packages for my user
        home.packages = with pkgs; [
          anki-bin
          audacity
          cockatrice
          discord
          element-desktop
          freecad
          gnome-graphs
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
          xournalpp
          zoom-us

          paulmiro.nato
        ];
      };
    };
}

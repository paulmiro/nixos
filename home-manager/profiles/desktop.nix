{ pkgs, lib, config, system-config, flake-self, ... }:
with lib;
{
  config = {
    paul = {
      programs.gnome-settings.enable = true;
      programs.vscode.enable = true;
      programs.ghostty.enable = true;

      programs.development = {
        android = true;
        c_cpp = true;
        go = true;
        godot = true;
        javascript = true;
        python = true;
      };
    };

    programs = {
      firefox = {
        enable = true;
        package = (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { });
      };
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      anki
      audacity
      discord
      element-desktop
      gnome-graphs
      gparted
      inkscape
      jellyfin-mpv-shim
      krita
      libreoffice
      mattermost-desktop
      mixxx
      mpv
      obs-studio
      obsidian
      oneko
      onlyoffice-bin
      pomodoro-gtk
      prusa-slicer
      orca-slicer
      rnote
      signal-desktop
      sl
      spotify
      switcheroo
      textpieces
      thunderbird-bin
      tor-browser
      ungoogled-chromium
      whatsapp-for-linux
      vdhcoapp
      xournalpp
      zoom-us

      flake-self.inputs.zen-browser.packages.${system}.default
    ]
    # only install these packages on x86_64-linux systems
    ++ lib.optionals (system-config.nixpkgs.hostPlatform.isx86_64) [
      nvtopPackages.full
    ];
  };
}

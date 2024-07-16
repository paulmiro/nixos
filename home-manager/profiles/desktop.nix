{ pkgs, lib, config, system-config, ... }:
with lib;
{
  config = {
    paul = {
      programs.direnv.enable = true;
      programs.gnome-settings.enable = true;
      programs.vscode.enable = true;
      programs.rbw.enable = true;

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
      ungoogled-chromium
      diebahn
      discord
      element-desktop
      errands
      firefox
      gnome-graphs
      gparted
      jellyfin-mpv-shim
      krita
      libreoffice
      mpv
      obs-studio
      obsidian
      oneko
      pomodoro-gtk
      protonmail-bridge
      prusa-slicer
      signal-desktop
      sl
      spotify
      switcheroo
      thunderbird-bin
      tor-browser
      whatsapp-for-linux
      xournalpp
      zoom-us
    ]
    # only install these packages on x86_64-linux systems
    ++ lib.optionals (system-config.nixpkgs.hostPlatform.isx86_64) [
      nvtopPackages.full
    ];
  };
}

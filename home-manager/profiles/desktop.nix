{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
      programs.direnv.enable = true;
      programs.development.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      discord
      firefox
      gparted
      jellyfin-mpv-shim
      libreoffice
      mpv
      obsidian
      protonmail-bridge
      prusa-slicer
      signal-desktop
      thunderbird-bin
      xournalpp
      zoom-us

      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection
    ];

  };
}

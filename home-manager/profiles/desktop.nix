{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      bun
      clang
      discord
      firefox
      go
      gparted
      jellyfin-mpv-shim
      libreoffice
      lua
      # gnomeExtensions.galaxy-buds-battery
      # gnomeExtensions.battery-health-charging
      mpv
      nvtop
      obsidian
      # p3x-onenote
      protonmail-bridge
      prusa-slicer
      ripgrep
      signal-desktop
      stylua
      thunderbird-bin
      xournalpp
      zoom-us
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows

      # example for a function building python with some packages
      (python3.withPackages (ps: with ps; [
        requests
        numpy
        jupyter
      ]))
    ];

  };
}

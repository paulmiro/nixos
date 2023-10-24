{ pkgs, lib, config, ... }:
let
  my-package = (pkgs.writeShellScriptBin "my-package" ''
    echo "I'm a function representing a package!"
  '');
in
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      bun
      discord
      firefox
      gparted
      jellyfin-mpv-shim
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

      # My packages

      # example for a function representing a package
      my-package

      # example for a function building python with some packages
      (python3.withPackages (ps: with ps; [
        requests
        numpy
      ]))

      # example for a function bulding a package from a shell script
      (writeShellScriptBin "bin-package" ''
        ${hello}/bin/hello
        echo "We can use packages from the nixpkgs collection!"
      '')
    ];

  };
}

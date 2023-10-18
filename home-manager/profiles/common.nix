{ config, pkgs, lib, flake-self, ... }:
with lib;
let
  my-package = (pkgs.writeShellScriptBin "my-package" ''
    echo "I'm a function representing a package!"
  '');
in
{
  config = {

    paul = {
      programs.git.enable = true;
      programs.vscode.enable = true;
      programs.zsh.enable = true;
    };

    # Home-manager nixpkgs config
    nixpkgs = {
      config = { allowUnfree = true; };
      overlays = [ ];
    };

    # Include man-pages
    manual.manpages.enable = true;

    # Install these packages for my user
    home.packages = with pkgs; [
      asciinema
      bun
      discord
      dnsutils
      firefox
      glances
      gparted
      nil
      nix-top
      nixpkgs-fmt
      nvtop
      obsidian
      protonmail-bridge
      prusa-slicer
      signal-desktop
      thunderbird-bin
      unzip
      xournalpp
      zoom-us

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

    home.stateVersion = "23.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

  };
}

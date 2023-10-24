{ config, pkgs, lib, flake-self, ... }:
with lib;
{
  config = {

    paul = {
      programs.git.enable = true;
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
      dnsutils
      glances
      nil
      nix-top
      nixpkgs-fmt
      unzip
      usbutils
    ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";

  };
}

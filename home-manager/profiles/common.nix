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
      firefox
      unzip
    ];

    home.stateVersion = "23.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

  };
}

{ config, pkgs, lib, flake-self, system-config, ... }:
with lib;
{
  config = {

    paul = {
      programs.direnv.enable = true;
      programs.git.enable = true;
      programs.ssh.enable = true;
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
      neofetch
      nil
      nix-tree
      nixpkgs-fmt
      openssl
      psmisc
      pwgen
      ripgrep
      unzip
      usbutils
      zellij
    ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";

  };
}

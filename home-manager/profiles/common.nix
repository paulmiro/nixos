{ config, pkgs, lib, flake-self, system-config, ... }:
with lib;
{
  config = {

    paul = {
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
      psmisc
      neofetch
      nil
      nix-top
      nixpkgs-fmt
      ripgrep
      unzip
      usbutils
    ]
    # only install these packages on x86_64-linux systems
    ++ lib.optionals (system-config.nixpkgs.hostPlatform.isx86_64) [
      nvtop
    ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";

  };
}

# This file gets imported for ALL home-manager profiles
{
  flake-self,
  pkgs,
  ...
}:
{
  config = {

    paul = {
      programs.direnv.enable = true;
      programs.git.enable = true;
      programs.neovim.enable = true;
      programs.ssh.enable = true;
      programs.zsh.enable = true;
      nixpkgs-config.enable = true;
    };

    # Home-manager nixpkgs config
    nixpkgs = {
      overlays = [ flake-self.overlays.paulmiro-overlay ];
    };

    # Include man-pages
    manual.manpages.enable = true;

    # Install these packages for my user
    home.packages = with pkgs; [
      asciinema
      croc
      dnsutils
      glances
      neofetch
      nil
      nixd
      nix-tree
      nixfmt-tree
      openssl
      psmisc
      pwgen
      ripgrep
      sops
      tmux
      unixtools.xxd
      unzip
      usbutils
      wget
      zellij
    ];

    programs.yazi.enable = true;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";

  };
}

{
  pkgs,
  ...
}:
{
  config = {

    paul = {
      programs.direnv.enable = true;
      programs.git.enable = true;
      programs.ssh.enable = true;
      programs.zsh.enable = true;
      programs.rbw.enable = true;
      nixpkgs-config.enable = true;
    };

    # Home-manager nixpkgs config
    nixpkgs = {
      overlays = [ ];
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
      nix-tree
      nixfmt-rfc-style # TODO: change to "nixfmt" once it is replaced
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

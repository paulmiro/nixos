# This file gets imported for ALL home-manager profiles
{
  flake-self,
  pkgs,
  ...
}:
{
  config = {

    paul = {
      direnv.enable = true;
      git.enable = true;
      neovim.enable = true;
      nixpkgs-config.enable = true;
      ssh.enable = true;
      zsh.enable = true;
      zellij.enable = true;
    };

    # Home-manager nixpkgs config
    nixpkgs = {
      overlays = [ flake-self.overlays.paulmiro-overlay ];
    };

    # Include man-pages
    manual.manpages.enable = true;

    # Install these packages for my user
    home.packages = with pkgs; [
      croc
      dnsutils
      gdu
      iputils
      jq
      nix-tree
      nixd
      nixfmt
      nixfmt-tree
      openssl
      psmisc
      ripgrep
      sops
      tmux
      unzip
      wget

      paulmiro.copypasta
      paulmiro.httpstatus
    ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";
  };
}

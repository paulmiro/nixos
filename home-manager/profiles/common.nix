{ self, ... }:
{
  flake.homeProfiles.common =
    {
      pkgs,
      ...
    }:
    {
      # TODO: switch to manual importing
      imports = (builtins.attrValues self.homeModules);

      config = {

        paul = {
          direnv.enable = true;
          git.enable = true;
          neovim.enable = true;
          nix-index.enable = true;
          nixpkgs-config.enable = true;
          ssh.enable = true;
          zsh.enable = true;
          zellij.enable = true;
        };

        # Home-manager nixpkgs config
        nixpkgs = {
          overlays = [ self.overlays.default ];
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
          timg
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
    };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.zsh; in
{
  options.paul.programs.zsh.enable = mkEnableOption "enable zsh";

  config = mkIf cfg.enable {
    paul.programs.starship.enable = true;

    home.shell.enableZshIntegration = true;

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      dotDir = ".config/zsh";

      sessionVariables = { ZDOTDIR = "$HOME/.config/zsh"; };

      initContent = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      '';

      history = {
        expireDuplicatesFirst = true;
        ignoreSpace = false;
        save = 15000;
        share = true;
      };

      plugins = [
        {
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
        {
          name = "zsh-bd";
          file = "bd.plugin.zsh";
          src = "${pkgs.zsh-bd}/share/zsh-bd";
        }
      ];

      shellAliases = {
        ## Nix

        # switching within a flake repository
        frb = "${pkgs.nixos-rebuild}/bin/nixos-rebuild --use-remote-sudo switch --flake";

        # switch another machine from within a flake repository
        lolly = "${pkgs.nix}/bin/nix run .\#lollypops --";

        # always execute nixos-rebuild with sudo for switching
        nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild --use-remote-sudo";

        # list syslinks into nix-store
        nix-list = "${pkgs.nix}/bin/nix-store --gc --print-roots";

        # nix-shell
        ns = "nix-shell -p";

        ## Systemd

        # show journalctl logs for a service
        logs = "${pkgs.systemd}/bin/journalctl -feau";

        ## lsd

        l = "lsd -1";
        ll = "lsd -l";
        la = "lsd -lA";
        lla = "lsd -lA";
        lt = "lsd --tree";
        lta = "lsd -A --tree";

        ## Default Parameters

        lsblk = "${pkgs.util-linux}/bin/lsblk -o name,mountpoint,label,size,type,uuid";

        # General Purpose
	
        c = "code .";
        q = "exit";
        r = "${pkgs.trashy}/bin/trash";

        ## Important

        uwu = "sudo";
        please = "sudo";
        cope = "code";
      };
    };

    programs = {
      # cooler cat
      bat.enable = true;

      # cooler htop
      btop.enable = true;

      # dir colors for ls and lsd
      dircolors.enable = true;

      # cooler top
      htop = {
        enable = true;
        settings = {
          show_cpu_frequency = true;
          show_cpu_temperature = true;
          show_cpu_usage = true;
          show_program_path = true;
          tree_view = false;
        };
      };

      # json processor
      jq.enable = true;

      # cooler ls
      lsd = {
        enable = true;
        # currently this option only sets default aliases
        # I'm turning it off because I don't want to override "ls"
        # and I prefer different shortcuts for some functions
        enableZshIntegration = false;
        settings = {
          icons.when = "never";
          blocks = [ "permission" "links" "user" "group" "size" "date" "git" "name" ];
          date = "+%Y-%m-%d %H:%M";
          indicators = true;
          hyperlink = "auto";
        };
      };

      # cooler cd
      zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.zsh;
in
{
  options.paul.programs.zsh = {
    enable = lib.mkEnableOption "enable zsh configuration";
  };

  config = lib.mkIf cfg.enable {
    paul.programs.starship.enable = true;

    home.shell.enableZshIntegration = true;

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      dotDir = "${config.xdg.configHome}/zsh";

      sessionVariables = {
        ZDOTDIR = "${config.xdg.configHome}/zsh";
      };

      initContent =
        let
          repo-script = pkgs.writeShellScript "repo-script" ''
            set -euo pipefail
            if [ -z $1 ]; then
              >&2 echo "error"
              echo .
              exit 1
            fi
            if [ $1 == "clone" ]; then
              if [ -z $2 ]; then
                >&2 echo "Please specify a repository"
                echo .
                exit 1
              fi
              REPO_FULL_NAME=$2
              REPO_OWNER_PATH=~/repos/$(dirname $REPO_FULL_NAME)
              REPO_FULL_PATH=~/repos/$2
              mkdir -p $REPO_OWNER_PATH
              if [ -e $REPO_FULL_PATH ]; then
                >&2 echo "Path already taken, still cd'ing there..."
                echo $REPO_FULL_PATH
                exit 1
              fi
              git clone --recursive git@github.com:$REPO_FULL_NAME.git $REPO_FULL_PATH
              echo $REPO_FULL_PATH
              exit 0
            fi
            >&2 echo "Unknown command: " $1
            echo .
            exit 1
          '';
        in
        ''
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word

          function repo () {
            cd $(${repo-script} $@)
          }
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

        # always execute nixos-rebuild with sudo for switching
        nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild --sudo";

        # list syslinks into nix-store
        nix-list = "${pkgs.nix}/bin/nix-store --gc --print-roots";

        # nix-shell
        ns = "nix-shell -p";

        ## Systemd

        # show journalctl logs for a service
        logs = "${pkgs.systemd}/bin/journalctl -feau";
        # list failed units
        failed = "${pkgs.systemd}/bin/systemctl list-units --failed";

        ## lsd

        l = "lsd -1";
        ll = "lsd -l";
        la = "lsd -lA";
        lla = "lsd -lA";
        lt = "lsd --tree";
        lta = "lsd -A --tree";

        ## Default Parameters

        lsblk = "${pkgs.util-linux}/bin/lsblk -o name,mountpoint,label,size,type,uuid";
        xclip = "${pkgs.xclip}/bin/xclip -selection c";

        # General Purpose

        c = "code .";
        e = "xdg-open .";
        q = "exit";
        qq = "clear && exit";
        r = "${pkgs.trashy}/bin/trash";
        y = "yazi";

        ## Important

        uwu = "sudo";
        please = "sudo";
        sduo = "sudo";
        suod = "sudo";
        cope = "code";
      };
    };

    programs = {

      # TODO atuin

      # cooler cat
      bat = {
        enable = true;
        config = {
          paging = "never";
          plain = true;
        };
      };

      # cooler htop
      btop = {
        enable = true;
        settings = {
          theme_background = false;
        };
      };

      # dir colors for ls and lsd
      dircolors.enable = true;

      # TODO eza

      # cooler find
      fd = {
        enable = true;
        hidden = true;
        ignores = [
          ".git/"
          ".direnv/"
        ];
      };

      # fuzzy find
      fzf = {
        enable = true;
        defaultCommand = "fd --type f"; # to respect .gitignore and fd's ignore list
        defaultOptions = [
          "--height 40%"
          "--border"
        ];
        changeDirWidgetCommand = "fd --type d";
        changeDirWidgetOptions = [
          "--preview 'tree -C {} | head -200'"
          "--height 40%"
          "--border"
        ];
        fileWidgetCommand = "fd --type f";
        fileWidgetOptions = [
          "--preview 'bat --color=always --line-range=:500 {}'"
          "--height 40%"
          "--border"
        ];
        historyWidgetOptions = [
          "--sort"
          "--height 40%"
          "--border"
        ];
      };

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
          blocks = [
            "permission"
            "links"
            "user"
            "group"
            "size"
            "date"
            "git"
            "name"
          ];
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

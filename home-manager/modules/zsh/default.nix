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

      initExtra = ''
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
        # nix

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

        # systemd

        # show journalctl logs for a service
        logs = "${pkgs.systemd}/bin/journalctl -feau";

        # Other
        lsblk = "${pkgs.util-linux}/bin/lsblk -o name,mountpoint,label,size,type,uuid";

        # general

        q = "exit";
        r = "${pkgs.trashy}/bin/trashy";

        # important

        uwu = "sudo";
        please = "sudo";
        cope = "code";
      };
    };

    programs.dircolors.enable = true;

    programs.htop = {
      enable = true;
      settings = {
        show_cpu_frequency = true;
        show_cpu_temperature = true;
        show_cpu_usage = true;
        show_program_path = true;
        tree_view = false;
      };
    };

    programs.jq.enable = true;

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.lsd = {
      enable = true;
      # enableAliases = true;
      settings = {
        blocks = [ "permission" "links" "user" "group" "size" "date" "git" "name" ];
        date = "+%Y-%m-%d %H:%M";
        indicators = true;
        hyperlink = "auto";
      };
    };
  };
}

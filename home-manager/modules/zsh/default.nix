{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.zsh; in
{
  options.paul.programs.zsh.enable = mkEnableOption "enable zsh";

  config = mkIf cfg.enable {

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      dotDir = ".config/zsh";

      sessionVariables = { ZDOTDIR = "/home/paulmiro/.config/zsh"; };

      initExtra = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # revert last n commits
        grv() {
          ${pkgs.git}/bin/git reset --soft HEAD~$1
        }

        # get github url of current repository
        gh() {
          echo $(${pkgs.git}/bin/git config --get remote.origin.url | sed -e 's/\(.*\)git@\(.*\):[0-9\/]*/https:\/\/\2\//g')
        }

        flake_update() {
          ${pkgs.nix}/bin/nix flake update
          ${pkgs.git}/bin/git add flake.lock
          ${pkgs.git}/bin/git commit -m "❅ flake.lock: update"
        }

        eval "$(${pkgs.h}/bin/h --setup ~/code)"
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

      shellAliases = rec {
        # git

        # clean up repository
        clean = "${pkgs.git}/bin/git clean -xdn";
        destroy = "${pkgs.git}/bin/git clean -xdf";

        # systemd / systemctl
        failed = "${pkgs.systemd}/bin/systemctl --failed";

        # ssh
        ssj = "${pkgs.openssh}/bin/ssh -J";

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

        # Other
        lsblk = "${pkgs.util-linux}/bin/lsblk -o name,mountpoint,label,size,type,uuid";

        # fun stuff

        # mensa
        mensa = "${pkgs.nix}/bin/nix run 'github:alexanderwallau/bonn-mensa' --";

      };
    };

    programs.zsh.oh-my-zsh = {
      enable = true;
      theme = "agnoster";
    };

    programs.dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

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
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}

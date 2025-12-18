{
  betternix,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.work;
in
{
  imports = [
    betternix.homeModules.default
  ];

  options.paul.work = {
    enable = lib.mkEnableOption "enable work stuff";
  };

  config = lib.mkIf cfg.enable {
    betternix.ssh.enable = true;

    programs.zsh = {
      shellAliases = {
        checkout = "${pkgs.writeShellScript "checkout" ''
          set -euo pipefail
          repoName=$1
          repoPath=~/source/''${repoName}
          if [ -e ''${repoPath} ]; then
            echo "Path already taken"
            exit 1
          fi
          svn checkout svn://betterstorage/bettertec/''${repoName}/trunk ''${repoPath}
        ''}";
      };
    };

    programs.ssh.matchBlocks = {
      "betterbuild" = {
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
      "git.bettertec.internal" = {
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
    };

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = lib.mkForce [
          "zen.desktop"
          "code.desktop"
          "idea-community.desktop"
          "dbeaver.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.Nautilus.desktop"
          "discord.desktop"
          "thunderbird.desktop"
        ];
      };
    };
    home.packages = with pkgs; [
      subversionClient
      # rapidsvn

      keepassxc

      android-studio
      dbeaver-bin
      jetbrains.idea-community-bin

      nodePackages."@angular/cli"
      nodejs
    ];
  };
}

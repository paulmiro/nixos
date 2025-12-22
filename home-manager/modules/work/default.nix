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

        nge = "ng extract-i18n";
        n = "ng serve -c dev";
        nde = "ng serve -c dev-de";
        nt = "ng serve -c test";
        ntde = "ng serve -c test-de";

        cpr = "${pkgs.writeShellScript "copy-report-common" ''
          cp ~/source/report-common/target/typescript-generator/report-common.d.ts ~/source/better-wms/src/app/common/report-common.d.ts
          npx prettier --write ~/source/better-wms/src/app/common/report-common.d.ts
        ''}";
        cpw = "${pkgs.writeShellScript "copy-wms-backend" ''
          cp ~/source/wms-backend/target/typescript-generator/wms-backend.d.ts ~/source/better-wms/src/app/common/wms-backend.d.ts
          npx prettier --write ~/source/better-wms/src/app/common/wms-backend.d.ts
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
          "org.gnome.Console.desktop"
          "org.gnome.Nautilus.desktop"
          "zen.desktop"
          "chromium-browser.desktop"
          "code.desktop"
          "idea.desktop"
          "dbeaver.desktop"
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
      jetbrains.idea

      nodePackages."@angular/cli"
      nodejs
    ];
  };
}

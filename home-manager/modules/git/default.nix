{
  config,
  git-agecrypt-armor,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.git;
in
{
  options.paul.git = {
    enable = lib.mkEnableOption "enable git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name = "Paul Mika Rohde";
        user.email = "git@paulmiro.de";

        init.defaultBranch = "main";

        pull.rebase = true;
        rebase.autoStatsh = true;
        merge.autoStatsh = true;

        alias = {
          ac =
            let
              script = pkgs.writeShellScript "git-ac" ''
                set -euo pipefail
                if [[ -z "''${1+x}" ]]; then
                  read -p "Commit message: " message
                else
                  message="$1"
                fi
                git add .
                git commit -m "$message"
              '';
            in
            "!${script}";
          acp =
            let
              script = pkgs.writeShellScript "git-acp" ''
                set -euo pipefail
                if [[ -z "''${1+x}" ]]; then
                  read -p "Commit message: " message
                else
                  message="$1"
                fi
                git add .
                git commit -m "$message"
                git push
              '';
            in
            "!${script}";
          pop = "stash pop";
          undo = "reset --soft HEAD~1";
          unstage = "reset HEAD --";
          # typos i tend to do
          statsh = "stash";
        };
      };
    };

    home.packages = with pkgs; [
      gh
      pre-commit
      git-agecrypt-armor.packages.${stdenv.hostPlatform.system}.default
    ];

  };
}

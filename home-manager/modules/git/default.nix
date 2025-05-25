{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.programs.git;
in
{
  options.paul.programs.git.enable = mkEnableOption "enable git";

  config = mkIf cfg.enable {

    programs = {
      git = {
        enable = true;
        lfs.enable = true;
        ignores = [
          ".vscode/"
        ];
        extraConfig = {
          pull.rebase = false;
          init.defaultBranch = "main";
        };
        userEmail = "30203227+paulmiro@users.noreply.github.com";
        userName = "paulmiro";
      };
    };
    home.packages = with pkgs; [
      pre-commit
      git-crypt
      transcrypt
    ];

  };
}

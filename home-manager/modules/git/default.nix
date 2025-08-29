{
  config,
  git-agecrypt-armor,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.git;
in
{
  options.paul.programs.git = {
    enable = lib.mkEnableOption "enable git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
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

    home.packages = with pkgs; [
      pre-commit
      git-agecrypt-armor.packages.${system}.default
    ];

  };
}

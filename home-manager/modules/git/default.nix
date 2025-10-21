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
      settings = {
        user.name = "Paul Mika Rohde";
        user.email = "git@paulmiro.de";

        init.defaultBranch = "main";

        pull.rebase = true;
        rebase.autostatsh = true;
        merge.autostatsh = true;
      };
    };

    home.packages = with pkgs; [
      pre-commit
      git-agecrypt-armor.packages.${system}.default
    ];

  };
}

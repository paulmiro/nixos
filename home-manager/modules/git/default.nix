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
      };
    };

    home.packages = with pkgs; [
      gh
      pre-commit
      git-agecrypt-armor.packages.${stdenv.hostPlatform.system}.default
    ];

  };
}

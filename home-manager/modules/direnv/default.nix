{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.paul.programs.direnv;
in
{

  options.paul.programs.direnv = {
    enable = lib.mkEnableOption "activate direnv";
  };

  config = lib.mkIf cfg.enable {

    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      git = {
        ignores = [ ".direnv/" ];
      };
      # vscode = { extensions = with pkgs.vscode-extensions; [ mkhl.direnv ]; };
    };

  };

}

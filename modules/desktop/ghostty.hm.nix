{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.ghostty;
in
{
  options.paul.ghostty = {
    enable = lib.mkEnableOption "enable ghostty";
    enableSshTerminfoFix = lib.mkEnableOption "force xterm-256color for ssh sessions";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        maximize = true;
        theme = "Molokai";
        font-family = "MesloLGS NF";
        font-size = 14;
        shellIntegrationFeatures = lib.mkIf cfg.enableSshTerminfoFix [
          "ssh-env"
        ];
      };
    };
  };
}

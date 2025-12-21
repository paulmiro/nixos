{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.protonmail-bridge;
in
{
  options.paul.protonmail-bridge = {
    enable = lib.mkEnableOption "enable protonmail-bridge";
  };

  config = lib.mkIf cfg.enable {
    services.protonmail-bridge = {
      enable = true;
      extraPackages = with pkgs; [
        gnome-keyring
      ];
    };
  };
}

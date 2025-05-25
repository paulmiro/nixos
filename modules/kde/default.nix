{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.paul.kde;
in
{

  options.paul.kde = {
    enable = lib.mkEnableOption "activate kde";
  };

  config = lib.mkIf cfg.enable {

    # Enable the Plasma 5 Desktop Environment.
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
    };

  };

}

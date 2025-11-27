{
  config,
  jovian,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.jovian;
in
{
  imports = [
    jovian.nixosModules.default
  ];

  options.paul.jovian = {
    enable = lib.mkEnableOption "activate jovian (steamos-like experience)";
  };

  config = lib.mkIf cfg.enable {
    jovian.steam = {
      enable = true;
      autoStart = true;
      user = "paulmiro";
      desktopSession = lib.mkIf config.paul.gnome.enable "gnome";
    };

    services.displayManager.gdm.enable = lib.mkIf config.paul.gnome.enable (lib.mkForce false);
  };
}

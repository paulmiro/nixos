{
  config,
  lib,

  inputs,
  ...
}:
let
  cfg = config.paul.jovian;
in
{
  imports = [
    inputs.jovian.nixosModules.default
    inputs.decky-store-proxy.nixosModules.default
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

    jovian.steamos.enableZram = false;

    jovian.decky-loader = {
      enable = true;
    };

    services.decky-store-proxy = {
      enable = true;
      settings.sources.github = {
        users = [ "paulmiro" ];
        topics = [ "decky-plugin" ];
      };
    };

    services.displayManager.defaultSession = lib.mkIf config.paul.gnome.enable (
      lib.mkForce "gamescope-wayland"
    );
    services.displayManager.gdm.enable = lib.mkIf config.paul.gnome.enable (lib.mkForce false);
  };
}

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

    # TODO: temp fix for Jovian-Experiments/Jovian-NixOS/issues/600
    # nixpkgs.overlays = [
    #   (final: prev: {
    #     jovianPackages = prev.jovianPackages.overrideScope (
    #       jfinal: jprev: {
    #         steam = jprev.steam.override {
    #           platformArgs = "-steamos3 -steampal -gamepadui -pipewire";
    #         };
    #       }
    #     );
    #   })
    # ];

    services.displayManager.defaultSession = lib.mkIf config.paul.gnome.enable (
      lib.mkForce "gamescope-wayland"
    );
    services.displayManager.gdm.enable = lib.mkIf config.paul.gnome.enable (lib.mkForce false);
  };
}

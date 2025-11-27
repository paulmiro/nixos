{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.qmk;
in
{
  options.paul.qmk = {
    enable = lib.mkEnableOption "activate qmk";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vial
    ];
    services.udev.packages = with pkgs; [
      vial
      qmk-udev-rules
    ];

    hardware.keyboard.qmk.enable = true;
  };
}

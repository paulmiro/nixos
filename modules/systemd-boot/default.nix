{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.systemd-boot;
in
{

  options.paul.systemd-boot = {
    enable = mkEnableOption "activate systemd-boot";
  };

  config = mkIf cfg.enable {

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

  };

}

{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.paul.systemd-boot;
in
{

  options.paul.systemd-boot = {
    enable = lib.mkEnableOption "activate systemd-boot";
  };

  config = lib.mkIf cfg.enable {

    # Use systemd-boot as the bootloader.
    boot.loader.systemd-boot.enable = true;

    # Whether the installation process is allowed to modify EFI boot variables.
    boot.loader.efi.canTouchEfiVariables = true;

    # Maximum number of latest generations in the boot menu.
    # Useful to prevent boot partition running out of disk space.
    boot.loader.systemd-boot.configurationLimit = 3;

    # Why not have memtest86 ready to go?
    boot.loader.systemd-boot.memtest86.enable = true;

  };

}

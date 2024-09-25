{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.grub;
in
{

  # to switch from systemd-boot to grub, change 
  # fileSystems."/boot" = {...}
  # to
  # fileSystems."/boot/efi" = {...}

  options.paul.grub = {
    enable = mkEnableOption "activate grub";
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        efi = {
          #canTouchEfiVariables = true;
          #efiSysMountPoint = "/boot/efi";
        };
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = true;
          useOSProber = true;
          configurationLimit = 2;
        };
      };
      tmp.cleanOnBoot = true;
    };
  };
}

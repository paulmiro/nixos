{
  lib,
  ...
}:
{
  services.qemuGuest.enable = true;

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  # During boot, resize the root partition to the size of the disk.
  # This makes upgrading the size of the vDisk easier.
  fileSystems."/".autoResize = true;
  boot.growPartition = true;

  boot = {
    loader = {
      timeout = 10;
      grub = {
        devices = [ "/dev/vda" ];
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 10;
      };
    };
  };

  networking.useDHCP = lib.mkDefault true;
}

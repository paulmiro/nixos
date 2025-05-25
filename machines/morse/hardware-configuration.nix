{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  primaryDisk = "/dev/vda";
in
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

  # We want to standardize our partitions and bootloaders across all providers.
  # -> BIOS boot partition
  # -> EFI System Partition
  # -> NixOS root partition (ext4)
  disko.devices.disk.main = {
    type = "disk";
    device = primaryDisk;
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = {
          size = "1024M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # During boot, resize the root partition to the size of the disk.
  # This makes upgrading the size of the vDisk easier.
  fileSystems."/".autoResize = true;
  boot.growPartition = true;

  boot = {
    loader = {
      timeout = 10;
      grub = {
        devices = [ primaryDisk ];
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 10;
      };
    };
    initrd = {
      availableKernelModules = [
        "9p"
        "9pnet_virtio"
        "ata_piix"
        "sr_mod"
        "uhci_hcd"
        "virtio_blk"
        "virtio_mmio"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
      ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    };
    # kernelParams = [ "console=ttyS0" ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

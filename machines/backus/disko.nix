{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
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

      tank_a_1 = {
        # HDD 1
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD80EZAZ-11TDBA0_7SJ4SK7W";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
      tank_a_2 = {
        # HDD 2
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD80EZAZ-11TDBA0_7SJ5X27W";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
    };

    zpool = {
      tank = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "tank_a_1"
                  "tank_a_2"
                ];
              }
            ];
          };
        };

        options = {
          ashift = "12";
        };

        rootFsOptions = {
          mountpoint = "none";
          atime = "off";
          snapdir = "visible";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {

          borg = {
            type = "zfs_fs";
            mountpoint = "/mnt/borg";
            options = {
              compression = "zstd-10";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
            };
          };

          dump = {
            type = "zfs_fs";
            mountpoint = "/mnt/dump";
            options = {
              compression = "zstd";
            };
          };

        };
      };
    };
  };
}

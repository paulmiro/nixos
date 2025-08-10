{
  disko.devices = {
    disk = {
      bootroot1 = {
        # Boot/Root SSD 1
        type = "disk";
        device = "/dev/by-id/nvme-SAMSUNG_MZVLB512HBJQ-000_S50HNX0N611770";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "8G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      # bootroot2 = {
      #   # Boot/Root SSD 2
      #   type = "disk";
      #   device = "/dev/by-uuid/AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEE02";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       ESP = {
      #         size = "8G";
      #         type = "EF00"; # TODO: is this even possible?
      #         content = {
      #           type = "filesystem";
      #           format = "vfat";
      #           mountpoint = "/boot2";
      #           mountOptions = [ "umask=0077" ];
      #         };
      #       };
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zroot";
      #         };
      #       };
      #     };
      #   };
      # };
      ssd1 = {
        # SSD 1
        type = "disk";
        device = "/dev/by-id/ata-SAMSUNG_SSD_PM851_2.5_7mm_256GB_S1CUNSAG126805";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zfast";
              };
            };
          };
        };
      };
      ssd2 = {
        # SSD 2
        type = "disk";
        device = "/dev/by-id/ata-SAMSUNG_SSD_PM851_2.5_7mm_256GB_S1CUNSAG125413";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zfast";
              };
            };
          };
        };
      };
      data1 = {
        # HDD 1
        type = "disk";
        device = "/dev/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27198536";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
      data2 = {
        # HDD 2
        type = "disk";
        device = "/dev/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27241387";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
      data3 = {
        # HDD 3
        type = "disk";
        device = "/dev/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27808397";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";

        mountpoint = "/";
        rootFsOptions = {
          "co.sun:auto-snapshot" = "false";
        };
        # postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };

      zfast = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "ssd1"
                  "ssd2"
                ];
              }
            ];
          };
        };

        rootFsOptions = {
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };

      zdata = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "zraid1";
                members = [
                  "data1"
                  "data2"
                  "data3"
                ];
              }
            ];
          };
        };

        rootFsOptions = {
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          arr = {
            type = "zfs_fs";
            mountpoint = "/mnt/arr";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
          data = {
            type = "zfs_fs";
            mountpoint = "/mnt/data";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}

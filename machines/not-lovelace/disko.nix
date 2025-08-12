{
  disko.devices = {
    disk = {
      zroot1 = {
        # Boot/Root SSD 1
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HBJQ-000_S50HNX0N611770";
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
      # zroot2 = {
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
      blitz1 = {
        # SSD 1
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_SSD_PM851_2.5_7mm_256GB_S1CUNSAG126805";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "blitz";
              };
            };
          };
        };
      };
      blitz2 = {
        # SSD 2
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_SSD_PM851_2.5_7mm_256GB_S1CUNSAG125413";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "blitz";
              };
            };
          };
        };
      };
      # tank1 = {
      #   # HDD 1
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27198536";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "tank";
      #         };
      #       };
      #     };
      #   };
      # };
      # tank2 = {
      #   # HDD 2
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27241387";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "tank";
      #         };
      #       };
      #     };
      #   };
      # };
      # tank3 = {
      #   # HDD 3
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-WDC_WD3200AAKS-75L9A0_WD-WCAV27808397";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "tank";
      #         };
      #       };
      #     };
      #   };
      # };
    };

    zpool = {
      zroot = {
        type = "zpool";
        # mode = "mirror";

        mountpoint = "/";
        rootFsOptions = {
          "co.sun:auto-snapshot" = "false";
        };
        # postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {

        };
      };

      blitz = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "blitz1"
                  "blitz2"
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
            mountpoint = "/nix";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
            };
          };
          var = {
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

      # tank = {
      #   type = "zpool";
      #   mode = {
      #     topology = {
      #       type = "topology";
      #       vdev = [
      #         {
      #           mode = "raidz1";
      #           members = [
      #             "tank1"
      #             "tank2"
      #             "tank3"
      #           ];
      #         }
      #       ];
      #     };
      #   };

      #   rootFsOptions = {
      #     mountpoint = "none";
      #     "com.sun:auto-snapshot" = "false";
      #   };

      #   datasets = {
      #     arr = {
      #       type = "zfs_fs";
      #       mountpoint = "/mnt/arr";
      #       options = {
      #         compression = "zstd";
      #         "com.sun:auto-snapshot" = "true";
      #       };
      #     };
      #     data = {
      #       type = "zfs_fs";
      #       mountpoint = "/mnt/data";
      #       options = {
      #         compression = "zstd";
      #         "com.sun:auto-snapshot" = "true";
      #       };
      #     };
      #   };
      # };
    };
  };
}

{
  disko.devices = {
    disk = {
      boot = {
        # Optane
        type = "disk";
        device = "/dev/disk/by-id/nvme-INTEL_MEMPEK1J016GAL_PHBT851203LM016N";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "100%";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
          };
        };
      };

      blitz_a_1 = {
        # SSD 1
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0WA69134L";
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
      blitz_a_2 = {
        # SSD 2
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsink_1TB_S6WSNJ0T700761P";
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

      tank_a_1 = {
        # HDD 1
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_24R0A0KCFJDH";
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
        device = "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_24R0A1ZUFJDH";
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
      tank_a_3 = {
        # HDD 3
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_24R0A20BFJDH";
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
      tank_a_4 = {
        # HDD 4
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_Z440A0BCFJDH";
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
      # tank_a_5 = {
      #   # HDD 5
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-TOSHIBA5"; # TODO replace
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
      blitz = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "blitz_a_1"
                  "blitz_a_2"
                ];
              }
            ];
          };
        };

        options = {
          ashift = "12";
        };

        rootFsOptions = {
          mountpoint = "/mnt/zpool/blitz";
          atime = "off";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {

          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "false";
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

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
            };
          };

          root_home = {
            type = "zfs_fs";
            mountpoint = "/root";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };

          tmp = {
            type = "zfs_fs";
            mountpoint = "/tmp";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "false";
            };
          };

          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var/lib" = {
            type = "zfs_fs";
          };
          "var/lib/immich" = {
            type = "zfs_fs";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var/lib/kanidm" = {
            type = "zfs_fs";
            options = {
              "com.sun:auto-snapshot" = "true";
              recordsize = "64K";
            };
          };
          "var/lib/jellyfin" = {
            type = "zfs_fs";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var/lib/transmission" = {
            type = "zfs_fs";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var/lib/sonarr" = {
            type = "zfs_fs";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var/lib/radarr" = {
            type = "zfs_fs";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };

        };
      };

      tank = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz1";
                members = [
                  "tank_a_1"
                  "tank_a_2"
                  "tank_a_3"
                  "tank_a_4"
                  #"tank_a_5"
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
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {

          arr = {
            type = "zfs_fs";
            mountpoint = "/mnt/arr";
            options = {
              compression = "zstd-10";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "true";
            };
          };

          photos = {
            type = "zfs_fs";
            mountpoint = "/mnt/photos";
            options = {
              compression = "zstd";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "true";
            };
          };

        };
      };
    };
  };
}

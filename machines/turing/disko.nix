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
      tank_a_5 = {
        # HDD 5
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_Z440A0A9FJDH";
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
          mountpoint = "none";
          atime = "off";
          snapdir = "visible";
          acltype = "posix";
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

          apps = {
            type = "zfs_fs";
            # mountpoint = "none"; # can't be set explicitly in disko
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "apps/immich" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/immich";
          };
          "apps/kanidm" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/kanidm";
            options = {
              recordsize = "64K";
            };
          };
          "apps/jellyfin" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/jellyfin";
            options = {
              compression = "zstd";
            };
          };
          "apps/audiobookshelf" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/audiobookshelf";
          };
          "apps/transmission" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/transmission";
          };
          "apps/sonarr" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/sonarr";
          };
          "apps/radarr" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/radarr";
          };
          "apps/hedgedoc" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/hedgedoc";
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
                  "tank_a_5"
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
              compression = "zstd-5";
              "com.sun:auto-snapshot" = "true";
            };
          };

          kanidm_home = {
            type = "zfs_fs";
            mountpoint = "/mnt/kanidm_home";
            options = {
              compression = "zstd-5";
              "com.sun:auto-snapshot" = "true";
            };
          };

        };
      };
    };
  };
}

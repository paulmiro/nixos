{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "16G";
          type = "EF00";
          device = "/dev/disk/by-uuid/F47A-3CBA";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };

        luks = {
          size = "100%";
          device = "/dev/disk/by-uuid/43c4b67b-f086-473d-ab86-c7ebea3d96e7";
          content = {
            type = "luks";
            name = "luks-43c4b67b-f086-473d-ab86-c7ebea3d96e7";
            content = {
              type = "btrfs";
              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}

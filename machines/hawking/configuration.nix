{
  ...
}:
{
  paul = {
    common-server.enable = true;
    dual-boot.enable = true;
    grub.enable = true;

    nvidia.enable = true;
    nvidia.driverVersion = "stable";

    tailscale.enable = true;
    tor-client.enable = true;

    docker.enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems."/mnt/windows/C" = {
    device = "/dev/disk/by-id/wwn-0x5002538d422793ef-part4";
    fsType = "ntfs";
  };

  fileSystems."/mnt/windows/D" = {
    device = "/dev/disk/by-id/wwn-0x50014ee20ee3e95b-part1";
    fsType = "ntfs";
  };

  fileSystems."/mnt/windows/G" = {
    device = "/dev/disk/by-id/wwn-0x500a0751e4b67f74-part2";
    fsType = "ntfs";
  };
}

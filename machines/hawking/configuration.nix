{
  lib,
  ...
}:
{
  paul = {
    common-desktop.enable = true;
    dual-boot.enable = true;
    gnome.enable = true;
    nvidia.enable = true;
    grub.enable = true;
    gaming.enable = true;
    tailscale.enable = true;
    tor-client.enable = true;
    qmk.enable = true;
    jovian.enable = true;
    home-manager.profile = "gaming";
  };

  hm.paul.gnome-settings.wallpaper = "zell-frieren.jpg";

  specialisation.desktop.configuration = {
    paul.jovian.enable = lib.mkForce false;
  };

  clan.core.deployment.requireExplicitUpdate = true;

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

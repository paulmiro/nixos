{
  private,
  ...
}:
{
  paul = {
    common-server.enable = true;
    grub.enable = true;

    tailscale = {
      enable = true;
      exitNode = true;
    };

    zfs = {
      enable = true;
      maxArcGB = 1;
    };

    home-manager.profile = "minimal";

    ramdash.client.enable = true;
    ramdash.client.memoryType = "ddr4";
  };

  services.qemuGuest.enable = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  clan.core.networking.buildHost = "paulmiro@morse.${private.domains.tailnet}";
}

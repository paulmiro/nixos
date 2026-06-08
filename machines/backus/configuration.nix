{
  ...
}:
{
  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;

    tailscale = {
      enable = true;
      exitNode = true;
    };

    zfs = {
      enable = true;
      maxArcGB = 1;
    };

    clan.buildHost = "morse";
  };

  services.qemuGuest.enable = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}

{
  config,
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
  };

  services.qemuGuest.enable = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  clan.core.networking.buildHost = "paulmiro@morse.${config.paul.private.domains.tailnet}";
}

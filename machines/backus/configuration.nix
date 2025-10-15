{
  ...
}:
{
  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    tailscale.enable = true;
    zfs = {
      enable = true;
      maxArcGB = 2;
    };
  };

  services.qemuGuest.enable = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  networking = {
    hostName = "backus";
  };

  clan.core.networking.targetHost = "backus";

  console.keyMap = "de"; # TODO: move this to locale module?

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
}

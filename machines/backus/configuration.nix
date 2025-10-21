{
  config,
  ...
}:
{
  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    tailscale.enable = true;
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

  networking = {
    hostName = "backus";
  };

  clan.core.networking.targetHost = "backus.${config.paul.private.domains.tailnet}";
  clan.core.networking.buildHost = "paulmiro@turing.${config.paul.private.domains.tailnet}";

  console.keyMap = "de"; # TODO: move this to locale module?

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
}

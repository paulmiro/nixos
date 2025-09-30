{
  ...
}:
{
  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostName = "turing";
  };

  clan.core.networking.targetHost = "turing";

  console.keyMap = "de"; # TODO: move to locale module?

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
}

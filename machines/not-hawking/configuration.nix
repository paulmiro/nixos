{
  config,
  ...
}:
{
  services.qemuGuest.enable = true;

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;

    # Exposed Services
    librespeedtest = {
      enable = true;
      openFirewall = true;
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Local Services
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    # radarr = {
    #   enable = true;
    #   openFirewall = true;
    # };
    # minecraft-servers = {
    #   vanilla = {
    #     enable = true;
    #     enableDyndns = true;
    #   };
    # };
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  clan.core.networking.targetHost = "not-hawking";

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "not-hawking";
    tempAddresses = "disabled";
  };

  # Configure console keymap
  console.keyMap = "de";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  # Running fstrim weekly is a good idea for VMs.
  # Empty blocks are returned to the host, which can then be used for other VMs.
  # It also reduces the size of the qcow2 image, which is good for backups.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

{
  ...
}:
{
  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    zfs.enable = true;

    nginx = {
      enable = true;
      enableGeoIP = true; # TODO: this should be enabled automatically, see dyndns
    };

    kanidm = {
      enable = true;
    };

    immich = {
      enable = true;
      enableNginx = true;
    };

    jellyfin = {
      enable = true;
      enableNginx = true;
      enableQuickSync = true;
    };

    audiobookshelf = {
      enable = true;
      enableNginx = true;
    };

    jellyseerr = {
      enable = true;
      enableNginx = true;
    };
    transmission = {
      enable = true;
      openTailscaleFirewall = true;
    };
    radarr = {
      enable = true;
      openTailscaleFirewall = true;
    };
    sonarr = {
      enable = true;
      openTailscaleFirewall = true;
    };
    prowlarr = {
      enable = true;
      openTailscaleFirewall = true;
    };

    hedgedoc = {
      enable = true;
      enableNginx = true;
    };

    karakeep = {
      enable = true;
      enableNginx = true;
    };

    stirling-pdf = {
      enable = true;
      enableNginx = true;
    };

    librespeedtest = {
      enable = true;
      enableNginx = true;
    };
  };

  networking = {
    hostName = "turing";
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node"
      "--operator=paulmiro"
    ];
  };

  clan.core.networking.targetHost = "turing";

  console.keyMap = "de"; # TODO: move this to locale module?

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
}

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
      maxArcGB = 96;
    };

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
      enableTailscaleService = true;
      openTailscaleFirewallPrivoxy = true;
    };
    radarr = {
      enable = true;
      enableTailscaleService = true;
    };
    sonarr = {
      enable = true;
      enableTailscaleService = true;
    };
    prowlarr = {
      enable = true;
      enableTailscaleService = true;
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
}

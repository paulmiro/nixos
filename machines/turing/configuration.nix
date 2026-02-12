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
      maxArcGB = 40;
    };

    nginx = {
      enable = true;
    };

    kanidm = {
      enableServer = true;
      enablePam = true;
      enablePamSsh = true;
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
    qbittorrent = {
      enable = true;
      enableTailscaleService = true;
      qui = {
        enable = true;
        enableTailscaleService = true;
      };
    };
    sabnzbd = {
      enable = true;
      enableTailscaleService = true;
    };
    pyload = {
      enable = true;
      enableTailscaleService = true;
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
    umlautadaptarr = {
      enable = true;
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

    outline = {
      enable = true;
      enableNginx = true;
    };
  };
}

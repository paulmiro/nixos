{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.qbittorrent;
  webuiPort = 8090;
  privoxyPort = 8118;
  serviceName = "qbittorrent-vpn-docker";
  # containerVersion = config.paul.versions.qbittorrent;
in
{
  options.paul.qbittorrent = {
    enable = lib.mkEnableOption "activate qbittorrent";
    enableTailscaleService = lib.mkEnableOption "enable tailscale service for qbittorrent";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    paul.user.transmission.enable = true;

    # HACK needed until we get a version with qbittorrent/qBittorrent#24218
    systemd.services.${serviceName}.serviceConfig.ExecStartPre =
      "${pkgs.coreutils}/bin/rm -f /var/lib/qbittorrent/config/config/lockfile";

    virtualisation.oci-containers.containers.qbittorrent-vpn = {
      inherit serviceName;
      image = "ghcr.io/hotio/qbittorrent:release-v5.2.1"; # TODO manage with versions module
      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "${config.clan.core.vars.generators.qbittorrent.files.wg0.path}:/config/wireguard/wg0.conf:ro"
        "/var/lib/qbittorrent/data:/data"

        "/mnt/arr/torrents:/mnt/arr/torrents"
      ];
      ports = [
        "${toString webuiPort}:${toString webuiPort}"
        "${toString privoxyPort}:8118"
      ];
      capabilities = {
        NET_ADMIN = true;
      };
      extraOptions = [
        # prevent "too many open files" error (default is 1024:524288)
        "--ulimit"
        "nofile=8192:524288"
      ];
      environment = {
        PUID = toString config.users.users.transmission.uid;
        PGID = toString config.users.groups.transmission.gid;
        UMASK = "000";

        TZ = config.time.timeZone;

        VPN_ENABLED = "true";
        VPN_NAMESERVERS = "1.1.1.1@853#cloudflare-dns.com";
        WEBUI_PORTS = "${toString webuiPort}/tcp,${toString privoxyPort}/tcp";

        PRIVOXY_ENABLED = "true";
      };

      environmentFiles = [
        config.clan.core.vars.generators.qbittorrent.files.env.path
      ];
    };

    paul.tailscale.services.qbt.port = lib.mkIf cfg.enableTailscaleService webuiPort;

    clan.core.state.qbittorrent = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/qbittorrent" ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    clan.core.vars.generators.qbittorrent = {
      prompts.wg0.description = "Wireguard config file for qbittorrent";
      prompts.wg0.type = "multiline";
      prompts.wg0.persist = true;
      files.wg0.owner = "transmission";

      prompts.forwarded-port.description = "Port that is forwarded through the VPN";
      prompts.forwarded-port.persist = false;

      files.env.secret = true;
      files.env.owner = "transmission";

      script = ''
        echo "
        VPN_AUTO_PORT_FORWARD="$(cat $prompts/forwarded-port)"
        " > $out/env
      '';
    };
  };
}

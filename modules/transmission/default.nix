{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.transmission;
in
{
  options.paul.transmission = {
    enable = lib.mkEnableOption "activate transmission";
    containerVersion = lib.mkOption {
      type = lib.types.str;
      default = "5.3.2";
      description = "transmission container version";
    };

    openTailscaleFirewall = lib.mkEnableOption "open firewall for transmission";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;
    paul.group.transmission.enable = true;

    users.users.transmission = {
      description = "Transmission BitTorrent user";
      uid = config.ids.uids.transmission; # 70
      group = "transmission";
    };

    virtualisation.oci-containers.containers.transmission-openvpn = {
      serviceName = "transmission-openvpn-docker";
      image = "haugene/transmission-openvpn:${cfg.containerVersion}";
      volumes = [
        "/var/lib/transmission/config:/config"
        "/var/lib/transmission/data:/data"
        "/var/lib/transmission/ovpn:/etc/openvpn/custom"

        "/mnt/arr/torrents:/data/torrents"
      ];
      ports = [
        "9091:9091/tcp"
        "8118:8118/tcp"
      ];
      capabilities = {
        NET_ADMIN = true;
      };
      environment = {
        PUID = toString config.users.users.transmission.uid;
        PGID = toString config.users.groups.transmission.gid;
        TZ = config.time.timeZone;

        OPENVPN_PROVIDER = "custom";
        OPENVPN_CONFIG = "AirVPN_Europe_TCP-443-Entry3";
        OPENVPN_USERNAME = "user";
        OPENVPN_PASSWORD = "pass";
        HEALTH_CHECK_HOST = "google.com";

        TRANSMISSION_DOWNLOAD_DIR = "/data/torrents";
        TRANSMISSION_WEB_UI = "transmissionic";

        GLOBAL_APPLY_PERMISSIONS = "false";
        LOCAL_NETWORK = "192.168.178.0/24,100.0.0.0/8,127.0.0.1/32";

        WEBPROXY_ENABLED = "true";
        WEBPROXY_PORT = "8118";
      };
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      9091
      8118
    ];
  };

}

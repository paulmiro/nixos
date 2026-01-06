{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.transmission;
  port = 9091;
  privoxyPort = 8118;
  serviceName = "transmission-openvpn-docker";
  containerVersion = "5.3.2";
in
{
  options.paul.transmission = {
    enable = lib.mkEnableOption "activate transmission";
    enableTailscaleService = lib.mkEnableOption "enable tailscale service for transmission";
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
      inherit serviceName;
      image = "haugene/transmission-openvpn:${containerVersion}";

      volumes = [
        "/var/lib/transmission/config:/config"
        "/var/lib/transmission/data:/data"
        "/var/lib/transmission/ovpn:/etc/openvpn/custom"

        "/mnt/arr/torrents:/mnt/arr/torrents"

        "/mnt/arr/torrents:/data/torrents" # it shouldn't be putting anything in here anymore, but i'll keep it for now just in case
      ];
      ports = [
        "${toString port}:9091/tcp"
        "${toString privoxyPort}:8118/tcp"
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
        TZ = config.time.timeZone;

        OPENVPN_PROVIDER = "custom";
        OPENVPN_CONFIG = "default";
        OPENVPN_USERNAME = "user";
        OPENVPN_PASSWORD = "pass";
        HEALTH_CHECK_HOST = "google.com";

        TRANSMISSION_DOWNLOAD_DIR = "/mnt/arr/torrents";
        TRANSMISSION_WEB_UI = "transmissionic";

        GLOBAL_APPLY_PERMISSIONS = "false";
        LOCAL_NETWORK = "192.168.178.0/24,100.0.0.0/8,127.0.0.1/32";

        WEBPROXY_ENABLED = "true";
        WEBPROXY_PORT = "8118";
      };

      environmentFiles = [
        config.clan.core.vars.generators.transmission.files.env.path
      ];
    };

    paul.tailscale.services.transmission.port = lib.mkIf cfg.enableTailscaleService port;

    clan.core.state.transmission = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/transmission" ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    clan.core.vars.generators.transmission = {
      prompts.rpc-password.description = "Transmission RPC Password (see bw)";
      prompts.rpc-password.type = "hidden";
      prompts.rpc-password.persist = false;

      files.env.secret = true;
      files.env.owner = "transmission";

      script = ''
        echo "
        TRANSMISSION_RPC_PASSWORD="$(cat $prompts/rpc-password)"
        TRANSMISSION_RPC_USERNAME="admin"
        TRANSMISSION_RPC_AUTHENTICATION_REQUIRED="true"
        " > $out/env
      '';
    };
  };

}

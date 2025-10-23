{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.jellyfin;
  serviceName = "jellyfin-docker";
in
{
  options.paul.jellyfin = {
    enable = lib.mkEnableOption "activate jellyfin";
    containerVersion = lib.mkOption {
      type = lib.types.str;
      default = "10.10.7";
      description = "jellyfin version";
    };

    openFirewall = lib.mkEnableOption "open firewall for jellyfin";

    enableNginx = lib.mkEnableOption "activate nginx proxy";
    enableDyndns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.jellyfin;
      description = "domain name for jellyfin";
    };

    enableQuickSync = lib.mkEnableOption "enable quicksync";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    virtualisation.oci-containers.containers.jellyfin = {
      inherit serviceName;
      image = "jellyfin/jellyfin:${cfg.containerVersion}";
      volumes = [
        "/var/lib/jellyfin/config:/config"
        "/var/lib/jellyfin/cache:/cache"
        "/mnt/arr/media:/data/media:ro"
      ];
      extraOptions = [
        "--network=host"
      ]
      ++ lib.optionals (cfg.enableQuickSync) [
        # get group ID with: `getent group render | cut -d: -f3`
        "--group-add=303"
        "--device=/dev/dri/renderD129:/dev/dri/renderD129"
      ]
      ++ lib.optionals (config.paul.nvidia.enable) [
        "--gpus"
        "all"
      ];
    };

    systemd.services.jellyfin-docker = {
      after = lib.mkIf config.paul.zfs.enable [
        "zfs.target"
      ];
    };

    clan.core.state.jellyfin = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/jellyfin" ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 8096 ];

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = cfg.enableDyndns;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        geo-ip = true;
        proxyWebsockets = true;
      };
    };
  };
}

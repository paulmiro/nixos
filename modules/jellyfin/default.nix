{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.jellyfin;
in
{

  options.paul.jellyfin = {
    enable = mkEnableOption "activate jellyfin";
    openFirewall = mkEnableOption "open firewall for jellyfin";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = mkOption {
      type = types.str;
      default = "***REMOVED***";
      description = "domain name for jellyfin";
    };

    enableQuickSync = mkEnableOption "enable quicksync";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      paul.nfs-mounts = {
        enableJellyfin = true;
        enableData = true;
      };

      virtualisation.oci-containers.backend = "docker";
      virtualisation.oci-containers.containers.jellyfin = {
        image = "jellyfin/jellyfin:10.8.13-1";
        user = "4001:4001";
        volumes = [
          "/mnt/nfs/jellyfin/config:/config"
          "/mnt/nfs/jellyfin/cache:/cache"
          "/mnt/nfs/data/media:/data/media:ro"
        ];
        extraOptions = [
          "--network=host"
        ] ++ lib.optionals (cfg.enableQuickSync) [
          # get group ID with: `getent group render | cut -d: -f3`
          "--group-add=\"303\""
          "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        ];
      };

      systemd.services.docker-jellyfin = {
        after = [
          "mnt-nfs-data.mount"
          "mnt-nfs-jellyfin.mount"
          "remote-fs.target"
        ];
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 8096 ];
    }

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    })

  ]);

}

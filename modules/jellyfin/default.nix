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
      default = "kino.kiste.dev";
      description = "domain name for jellyfin";
    };

    enableQuickSync = mkEnableOption "enable quicksync";

    containerVersion = mkOption {
      type = types.str;
      default = "10.9.5";
      description = "jellyfin version";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      paul.nfs-mounts = {
        enableJellyfin = true;
        enableArr = true;
      };

      /*
      // This needs some really complicated migration
      // https://jellyfin.org/docs/general/administration/migrate/
      // the script only works on windows, so this will propably be way too much work to be worth it

      services.jellyfin = {
        enable = true;
        dataDir = "/mnt/nfs/jellyfin";
        openFirewall = cfg.openFirewall;
      };

      users.users."jellyfin".uid = 4001;
      users.groups."jellyfin".gid = 4001;

      systemd.services.jellyfin = {
        after = [
          "mnt-nfs-arr.mount"
          "mnt-nfs-jellyfin.mount"
          "remote-fs.target"
        ];
      };
      */

      virtualisation.oci-containers.backend = "docker";
      virtualisation.oci-containers.containers.jellyfin = {
        image = "jellyfin/jellyfin:${cfg.containerVersion}";
        user = "4001:4001";
        volumes = [
          "/mnt/nfs/jellyfin/config:/config"
          "/mnt/nfs/jellyfin/cache:/cache"
          "/mnt/nfs/arr/media:/data/media:ro"
        ];
        extraOptions = [
          "--network=host"
        ] ++ lib.optionals (cfg.enableQuickSync) [
          # get group ID with: `getent group render | cut -d: -f3`
          "--group-add=\"303\""
          "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        ] ++ lib.optionals (config.paul.nvidia.enable) [
          "--gpus"
          "all"
        ];
      };

      systemd.services.docker-jellyfin = {
        after = [
          "mnt-nfs-arr.mount"
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
        domains = [ cfg.domain "jellyfin.pamiro.net" ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          geo-ip = true;
        };
      };

      # this domain is deprecated and only kept here to give my users some time to switch over
      services.nginx.virtualHosts."jellyfin.pamiro.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          geo-ip = true;
        };
      };
    })

  ]);

}

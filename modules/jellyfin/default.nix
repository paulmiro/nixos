{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.jellyfin;
in
{

  options.paul.jellyfin = {
    enable = mkEnableOption "activate jellyifn";
    openFirewall = mkEnableOption "open firewall for jellyfin";
    enableNginx = mkEnableOption "activate nginx proxy";
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
        extraOptions = [ "--network=host" ];
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

      services.nginx.virtualHosts."jellyfin.pamiro.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    })

  ]);

}

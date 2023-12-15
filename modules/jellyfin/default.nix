# It might make sense to migrate to OCI:
# https://search.nixos.org/options?channel=unstable&type=packages&query=virtualisation.oci-containers.containers
# Would require us to mount NFS shares manually though.
# OCI implementation would look like this (NFS mounts seperate):
# oci-containers.containers.jellyfin = {
#   image = "jellyfin/jellyfin";
#   user = "4001:4001";
#   volumes = [
#     "volume_name:/path/inside/container"
#     "/path/on/host:/path/inside/container"
#   ];
#   extraOptions = [ "--network=host" ];
# };
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

  config = mkIf cfg.enable
    {
      paul.docker.enable = true;

      systemd.services.jellyfin = {
        description = "Jellyfin media server docker-compose service";
        wantedBy = [ "multi-user.target" ];
        after = [ "docker.service" "docker.socket" ];
        serviceConfig = {
          ExecStart = "${pkgs.docker}/bin/docker compose -f ${./docker-compose.yml} up";
          Restart = "on-failure";
        };
      };
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 8096 ];
    } // mkIf (cfg.enableNginx && cfg.enable)
    {
      paul.nginx.enable = true;

      services.nginx.virtualHosts."***REMOVED***" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    };

}

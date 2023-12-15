# It might make sense to migrate to OCI:
# https://search.nixos.org/options?channel=unstable&type=packages&query=virtualisation.oci-containers.containers
# Would require us to mount NFS shares manually though.
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
      virtualisation.docker.enable = true;
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
      # if nginx for jellyfin is enabled, our common nginx module needs to be enabled
      paul.nginx.enable = true;
      services.nginx.virtualHosts."jellyfin.pamiro.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    };

}

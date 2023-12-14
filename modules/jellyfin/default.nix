{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.jellyfin;
in
{

  options.paul.jellyfin = {
    enable = mkEnableOption "activate jellyifn";
    enableNginx = mkEnableOption "activate nginx proxy";
  };

  config = mkIf cfg.enable {

/*
    systemd.services.jellyfin =
      let
        compose-file = fileContents ./docker-compose.yml;
      in
      {
        description = "a docker compose app.";
        wantedBy = [ "multi-user.target" ];
        after = [ "docker.service" "docker.socket" ];
        serviceConfig = mkMerge [
          {
            User = "root";
            Group = "root";
            ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} up";
            Restart = "on-failure";
          }
        ];
        preStop = "${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} down";
      };
*/
    services.nginx.virtualHosts."***REMOVED***" = mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };

  };
}

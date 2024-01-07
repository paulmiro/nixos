{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.jellyseerr;
in
{

  options.paul.jellyseerr = {
    enable = mkEnableOption "activate jellyseerr";
    openFirewall = mkEnableOption "allow jellyseerr port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 5055;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "jellyseerr.pamiro.net";
      description = "domain name for jellyseerr";
    };
  };


  config = mkIf cfg.enable (mkMerge [
    {
      paul.sonarr.enable = true;
      paul.radarr.enable = true;

      services.jellyseerr = {
        enable = true;
        port = cfg.port;
        openFirewall = cfg.openFirewall;
      };

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
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
        };
        enableGeoBlocking = true;
      };
    })

  ]);

}

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
      default = "***REMOVED***";
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
        domains = [ cfg.domain "***REMOVED***" ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          geo-ip = true;
        };
      };

      # this domain is deprecated and only kept here to give my users some time to switch over
      services.nginx.virtualHosts."***REMOVED***" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "301 https://${cfg.domain}";
          geo-ip = true;
        };
      };
    })

  ]);

}

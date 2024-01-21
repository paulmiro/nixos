{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.plex;
in
{

  options.paul.plex = {
    enable = mkEnableOption "activate plex";
    openFirewall = mkEnableOption "allow plex port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = mkOption {
      type = types.str;
      default = "plex.pamiro.net";
      description = "domain name for plex";
    };
  };


  config = mkIf cfg.enable (mkMerge [
    {
      services.plex = {
        enable = true;
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
          proxyPass = "http://127.0.0.1:32400";
        };
        geo-ip = true;
      };
    })

  ]);

}

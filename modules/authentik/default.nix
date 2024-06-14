###################################################
# ⚠️ WARNING ⚠️
# This module is VERY unfinished. the current version only exists to let the CI build it
###################################################
{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.authentik;
in
{
  options.paul.authentik = {
    enable = mkEnableOption "activate authentik";
    enableLdap = mkEnableOption "activate ldap";
    openFirewall = mkEnableOption "open firewall for authentik";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 9100;
      description = "port to listen on for http";
    };

    httpsPort = mkOption {
      type = types.port;
      default = 9443;
      description = "port to listen on for https";
    };

    domain = mkOption {
      type = types.str;
      default = "auth.${builtins.readFile ../../domains/_base}";
      description = "domain name for authentik";
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.authentik = {
        enable = true;
      };

      paul.nfs-mounts = {
        enableAuthentik = true;
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        cfg.port
        cfg.httpsPort
      ];
    }

    (mkIf cfg.enableLdap {
      services.authentik-ldap = {
        enable = true;
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        389 # ldap
        636 # ldaps
      ];
    })

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx = {
        virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://authentik";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade_keepalive;
            '';
            geo-ip = true;
          };
        };
        appendHttpConfig = ''
          upstream authentik {
              server 127.0.0.1:${toString cfg.port};
              # Improve performance by keeping some connections alive.
              keepalive 10;
          }
          map $http_upgrade $connection_upgrade_keepalive {
              default upgrade;
              '''      ''';
          }
        '';
      };
    })

  ]);

}

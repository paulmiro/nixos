{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.auth;
in
{

  options.paul.auth = {
    enable = mkEnableOption "activate auth";
    openFirewall = mkEnableOption "allow auth ports in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    keycloak = {
      enable = mkEnableOption "activate keycloak";
      httpPort = mkOption {
        type = types.port;
        default = 8080;
        description = "Port to listen on";
      };
      httpsPort = mkOption {
        type = types.port;
        default = 8443;
        description = "Port to listen on";
      };
      domain = mkOption {
        type = types.str;
        default = "auth.pamiro.net";
        description = "Domain to use for keycloak";
      };
      openFirewall = mkEnableOption "allow keycloak port in firewall";
    };


  };


  config = mkIf cfg.enable (mkMerge [
    {

      services.keycloak = {
        enable = true;
        settings = {
          hostname = cfg.keycloak.domain;
          hostname-strict-backchannel = true;
          http-port = cfg.keycloak.httpPort;
          https-port = cfg.keycloak.httpsPort;
        };
        initialAdminPassword = "e6Wcm0RrtegMEHl";  # change on first login
        sslCertificate = "/run/keys/ssl_cert";
        sslCertificateKey = "/run/keys/ssl_key";
        database.passwordFile = "/run/keys/keycloak_db_password";
      };
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.keycloak.httpPort cfg.keycloak.httpsPort ];

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
          geo-ip = true;
        };
      };
    })

  ]);

}

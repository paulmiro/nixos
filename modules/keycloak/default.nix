{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.keycloak;
in
{

  options.paul.keycloak = {
    enable = mkEnableOption "activate keycloak";
    httpPort = mkOption {
      type = types.port;
      default = 10480;
      description = "Port to listen on, should only be used for connections between nginx and keycloak";
    };
    domain = mkOption {
      type = types.str;
      default = "auth.kiste.dev";
      description = "Domain to use for keycloak";
    };
    openFirewall = mkEnableOption "allow keycloak port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };
    dbPasswordFilePath = mkOption {
      type = types.str;
      default = "/run/keys/keycloak-db-password";
      description = "Path to database password file";
    };

  };


  config = mkIf cfg.enable (mkMerge [
    {
      environment.noXlibs = false;

      paul.postgres.enable = true;

      services.keycloak =
        {
          enable = true;
          settings = {
            hostname = cfg.domain;
            #hostname-strict-backchannel = true;

            proxy = "edge";

            http-enabled = true;
            http-host = "127.0.0.1";
            http-port = cfg.httpPort;
          };
          database = {
            type = "postgresql";
            createLocally = true;

            username = "keycloak";
            passwordFile = cfg.dbPasswordFilePath;
          };
          initialAdminPassword = "CHANGEME---074b2f14b546e6718a589ca0d7ec8a47b48f2fceb7df5f7bf0655982d62399a2";
        };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.httpPort ];

      lollypops.secrets.files."keycloak-db-password" = {
        cmd = "bw get item keycloak | jq -r '.fields[] | select(.name == \"database-password\") | .value'";
        path = cfg.dbPasswordFilePath;
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
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.httpPort}";
          geo-ip = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    })

  ]);

}

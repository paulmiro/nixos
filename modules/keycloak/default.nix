{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.keycloak;
in
{

  imports = [
    ./themes
  ];

  options.paul.keycloak = {
    enable = mkEnableOption "activate keycloak";
    httpPort = mkOption {
      type = types.port;
      default = 10480;
      description = "Port to listen on, should only be used for connections between nginx and keycloak";
    };
    domain = mkOption {
      type = types.str;
      default = "***REMOVED***";
      description = "Domain to use for keycloak";
    };
    openFirewall = mkEnableOption "allow keycloak port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };
    dbPasswordFile = mkOption {
      type = types.str;
      default = "/run/keys/keycloak-db-password";
      description = "Path to database password file";
    };
    enableCustomTheme = mkOption {
      type = types.bool;
      default = true;
      description = "enable custom theme";
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
            hostname-strict-backchannel = true;

            proxy = "edge";

            http-enabled = true;
            http-host = "127.0.0.1";
            http-port = cfg.httpPort;
          };
          database = {
            type = "postgresql";
            createLocally = true;

            username = "keycloak";
            passwordFile = cfg.dbPasswordFile;
          };
          initialAdminPassword = "CHANGEME---074b2f14b546e6718a589ca0d7ec8a47b48f2fceb7df5f7bf0655982d62399a2";
        };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.httpPort ];

      lollypops.secrets.files."keycloak-db-password" = {
        cmd = "rbw get keycloak --field=database-password";
        path = cfg.dbPasswordFile;
      };

      systemd.services.keycloak = {
        after = [
          "network.target"
          (mkIf config.services.openldap.enable "openldap.service")
        ];
        serviceConfig = {
          ExecStartPre = mkIf config.services.openldap.enable "${pkgs.coreutils}/bin/sleep 2"; # TODO: test if this is needed / enough
        };
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

    (mkIf cfg.enableCustomTheme {
      services.keycloak.themes = with pkgs ; {
        keywind = custom_keycloak_themes.keywind;
      };
    })
  ]);

}

{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.paul.authentik;
in
{
  imports = [ ./vhostOptions.nix ];

  options.paul.authentik = with lib; {
    enable = mkEnableOption "activate authentik";
    enableLdap = mkEnableOption "activate ldap";

    openFirewall = mkEnableOption "open firewall for authentik";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.authentik;
      description = "domain name for authentik";
    };

    emailAdress = mkOption {
      type = types.str;
      default = "account@" + config.paul.private.domains.authentik;
      description = "email adress for authentik";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/run/keys/authentik.env";
      description = "path to the secrets environment file";
    };

    environmentFileLdap = mkOption {
      type = types.str;
      default = "/run/keys/authentik-ldap.env";
      description = "path to the ldap environment file";
    };

  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.authentik = {
          enable = true;
          environmentFile = cfg.environmentFile;
          settings = {
            email = {
              host = "mail.smtp2go.com";
              port = 2525;
              username = config.paul.private.smtp2go_username_authentik;
              use_tls = true;
              use_ssl = false;
              from = cfg.emailAdress;
            };
            disable_startup_analytics = true;
            error_reporting.enabled = false;
            avatars = "initials";
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 9443 ];

        lollypops.secrets.files."authentik-environment" = {
          cmd = ''
            echo "
            AUTHENTIK_SECRET_KEY="$(rbw get authentik-secret-key)"
            AUTHENTIK_EMAIL__PASSWORD="$(rbw get authentik-email-password)"
            "'';
          path = cfg.environmentFile;
        };

        paul.postgres.enable = true; # this enables database backups
      }

      (lib.mkIf cfg.enableLdap {
        services.authentik-ldap = {
          enable = true;
          environmentFile = cfg.environmentFileLdap;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
          389 # ldap
          636 # ldaps
        ];

        lollypops.secrets.files."authentik-ldap-environment" = {
          cmd = ''
            echo "
            AUTHENTIK_HOST="https://${cfg.domain}"
            AUTHENTIK_TOKEN="$(rbw get authentik-ldap-token)"
            AUTHENTIK_INSECURE="false"
            "'';
          path = cfg.environmentFileLdap;
        };
      })

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        paul.dyndns.domains = lib.mkIf cfg.enableDyndns [ cfg.domain ];

        services.authentik.nginx = {
          enable = true;
          enableACME = true;
          host = cfg.domain;
        };

        services.nginx = {
          virtualHosts."${cfg.domain}" = {
            locations."/" = {
              geo-ip = true;
            };
          };
        };
      })

    ]
  );

}

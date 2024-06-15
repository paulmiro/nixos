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

    domain = mkOption {
      type = types.str;
      default = "auth.${builtins.readFile ../../domains/_base}";
      description = "domain name for authentik";
    };

    emailAdress = mkOption {
      type = types.str;
      default = "account@${builtins.readFile ../../domains/_base}";
      description = "email adress for authentik";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/run/keys/authentik.env";
      description = "path to the secrets environment file";
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.authentik = {
        enable = true;
        environmentFile = cfg.environmentFile;
        settings = {
          email = {
            host = "mail.smtp2go.com";
            port = 2525;
            username = cfg.emailAdress;
            use_tls = true;
            use_ssl = false;
            from = cfg.emailAdress;
          };
          disable_startup_analytics = true;
          error_reporting.enabled = false;
          avatars = "initials";
          #storage.media.file.path = "/mnt/nfs/authentik/media"; # defaults to /var/lib/authentik/media
        };
      };

      #paul.nfs-mounts = {
      #  enableAuthentik = true;
      #};

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 9443 ];

      lollypops.secrets.files."authentik-environment" = {
        cmd = ''
          echo "
          AUTHENTIK_SECRET_KEY="$(rbw get authentik-secret-key)"
          AUTHENTIK_EMAIL__PASSWORD="$(rbw get authentik-email-password)"
          "'';
        path = cfg.environmentFile;
      };
    }

    (mkIf cfg.enableLdap {
      services.authentik-ldap = {
        enable = true;
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        389 # ldap
        636 # ldaps
      ];

      lollypops.secrets.files."authentik-ldap-environment" = {
        cmd = ''
          echo "
          AUTHENTIK_TOKEN="$(rbw get authentik-ldap-token)"
          "'';
        path = cfg.environmentFile;
      };
    })

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;

      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

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

  ]);

}

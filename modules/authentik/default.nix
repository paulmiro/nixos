{
  authentik-nix,
  config,
  lib,
  ...
}:
let
  cfg = config.paul.authentik;
in
{
  imports = [
    authentik-nix.nixosModules.default
    ./vhostOptions.nix
  ];

  options.paul.authentik = {
    enable = lib.mkEnableOption "activate authentik";
    enableLdap = lib.mkEnableOption "activate ldap";

    openFirewall = lib.mkEnableOption "open firewall for authentik";
    enableNginx = lib.mkEnableOption "activate nginx proxy";
    enableDyndns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.authentik;
      description = "domain name for authentik";
    };

    emailAdress = lib.mkOption {
      type = lib.types.str;
      default = "account@" + config.paul.private.domains.authentik;
      description = "email adress for authentik";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.authentik = {
          enable = true;
          environmentFile = config.clan.core.vars.generators.authentik.files.env.path;
          settings = {
            email = {
              host = "mail.smtp2go.com";
              port = 2525;
              username = config.paul.private.misc.smtp2go_username_authentik;
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

        clan.core.vars.generators.authentik = {
          prompts.secret-key.description = "Secret Key for Authentik (see bw)";
          prompts.secret-key.type = "hidden";
          prompts.secret-key.persist = false;

          prompts.smtp-password.description = "SMTP Password for Authentik (see bw)";
          prompts.smtp-password.type = "hidden";
          prompts.smtp-password.persist = false;

          files.env.secret = true;

          script = ''
            echo "
            AUTHENTIK_SECRET_KEY="$(cat $prompts/secret-key)"
            AUTHENTIK_EMAIL__PASSWORD="$(cat $prompts/smtp-password)"
            " > $out/env
          '';
        };

        paul.postgres.enable = true; # this enables database backups
      }

      (lib.mkIf cfg.enableLdap {
        services.authentik-ldap = {
          enable = true;
          environmentFile = config.clan.core.vars.generators.authentik-ldap.files.env.path;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
          389 # ldap
          636 # ldaps
        ];

        clan.core.vars.generators.authentik-ldap = {
          prompts.api-token.description = "API Token for Authentik-LDAP (see bw)";
          prompts.api-token.type = "hidden";
          prompts.api-token.persist = false;

          files.env.secret = true;

          script = ''
            echo "
            AUTHENTIK_HOST="https://${cfg.domain}"
            AUTHENTIK_TOKEN="$(cat $prompts/api-token)"
            AUTHENTIK_INSECURE="false"
            " > $out/env
          '';
        };
      })

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.authentik.nginx = {
          enable = true;
          enableACME = true;
          host = cfg.domain;
        };

        services.nginx = {
          virtualHosts."${cfg.domain}" = {
            enableDyndns = cfg.enableDyndns;
            locations."/" = {
              geo-ip = true;
            };
          };
        };
      })
    ]
  );
}

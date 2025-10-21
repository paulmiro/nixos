{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.hedgedoc;
in
{
  options.paul.hedgedoc = {
    enable = lib.mkEnableOption "enable hedgedoc";
    enableNginx = lib.mkEnableOption "enable nginx proxy for hedgedoc";
    openFirewall = lib.mkEnableOption "open firewall for hedgedoc";

    port = lib.mkOption {
      type = lib.types.port;
      default = 19103; # default would be 3000
      description = "port for hedgedoc";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.hedgedoc;
      description = "domain name for hedgedoc";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.hedgedoc = {
          enable = true;
          environmentFile = config.clan.core.vars.generators.hedgedoc.files.env.path;
          settings = {
            port = cfg.port;
            host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
            domain = lib.mkIf cfg.enableNginx cfg.domain;
            protocolUseSSL = cfg.enableNginx;
            allowAnonymous = true;
            allowAnonymousEdits = true;
            allowFreeUrl = true;
            requireFreeURLAuthentication = true;
            defaultPermissions = "limited";
            sessionSecret = "$SESSION_SECRET"; # this gets replaced by the env file at runtime

            email = false;
            oauth2 = {
              baseUrl = "https://${config.paul.private.domains.kanidm}";
              providerName = config.paul.private.misc.kanidm_display_name;
              clientID = "hedgedoc";
              clientSecret = "$OAUTH2_CLIENT_SECRET";
              scope = "openid email profile";
              userProfileURL = "https://${config.paul.private.domains.kanidm}/oauth2/openid/hedgedoc/userinfo";
              tokenURL = "https://${config.paul.private.domains.kanidm}/oauth2/token";
              authorizationURL = "https://${config.paul.private.domains.kanidm}/ui/oauth2";
              userProfileUsernameAttr = "preferred_username";
              userProfileDisplayNameAttr = "name";
              userProfileEmailAttr = "email";
            };
          };
        };

        clan.core.vars.generators.hedgedoc = {
          prompts.oauth2-client-secret.description = "Hedgedoc OAuth2 Client Secret";
          prompts.oauth2-client-secret.type = "hidden";
          prompts.oauth2-client-secret.persist = false;

          files.env.secret = true;

          runtimeInputs = [ pkgs.pwgen ];

          script = ''
            echo "\
            OAUTH2_CLIENT_SECRET="$(cat $prompts/oauth2-client-secret)"
            SESSION_SECRET="$(pwgen -s 64 1)"
            " > $out/env
          '';
        };

        clan.core.state.hedgedoc = {
          useZfsSnapshots = true;
          folders = [ "/var/lib/hedgedoc" ];
          servicesToStop = [ "hedgedoc.service" ];
        };
      }
      (lib.mkIf cfg.openFirewall {
        networking.firewall.allowedTCPPorts = [ cfg.port ];
      })
      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      })
    ]
  );
}

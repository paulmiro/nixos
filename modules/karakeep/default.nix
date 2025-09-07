{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.karakeep;
in
{
  options.paul.karakeep = {
    enable = lib.mkEnableOption "Enable karakeep";
    enableNginx = lib.mkEnableOption "Enable karakeep nginx";
    openFirewall = lib.mkEnableOption "Enable karakeep openFirewall";

    port = lib.mkOption {
      type = lib.types.int;
      default = 19104;
      description = "port for karakeep";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.karakeep;
      description = "domain name for karakeep";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.karakeep = {
          enable = true;
          extraEnvironment = {
            PORT = toString cfg.port;
            NEXTAUTH_URL = "https://${cfg.domain}";
            DISABLE_NEW_RELEASE_CHECK = "true";
            OAUTH_CLIENT_ID = "karakeep";
            OAUTH_WELLKNOWN_URL = "https://${config.paul.private.domains.kanidm}/oauth2/openid/karakeep/.well-known/openid-configuration";
            OAUTH_PROVIDER_NAME = config.paul.private.misc.kanidm_display_name;
            DISABLE_PASSWORD_AUTH = "true";
          };
          environmentFile = config.clan.core.vars.generators.karakeep.files.env.path;
        };

        services.meilisearch = {
          # this is required because state-version < 25.05 sets the package to 1.11
          # TODO: 25.11: remove this (assuming they actually removed meilisearch_1_11)
          # -> also check if the dumpless upgrade is made the default, and remove that too if that's the case
          package = pkgs.meilisearch;
          # this allows the database to be updated automatically without having to dump and then re-import it
          settings.experimental_dumpless_upgrade = true;
        };

        # surrealdb/surrealdb/issues/6153#issuecomment-3135333587
        systemd.services.meilisearch.serviceConfig.ProcSubset = lib.mkForce "all";

        clan.core.vars.generators.karakeep = {
          prompts.oauth-client-secret.description = "Karakeep OAuth2 Client Secret";
          prompts.oauth-client-secret.type = "hidden";
          prompts.oauth-client-secret.persist = false;

          prompts.openai-api-key.description = "Karakeep OpenAI API Key";
          prompts.openai-api-key.type = "hidden";
          prompts.openai-api-key.persist = false;

          files.env.secret = true;

          script = ''
            echo "\
            OAUTH_CLIENT_SECRET="$(cat $prompts/oauth-client-secret)"
            OPENAI_API_KEY="$(cat $prompts/openai-api-key)"
            " > $out/env
          '';
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
            geo-ip = true;
          };
        };
      })
    ]
  );
}

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
            OAUTH_WELLKNOWN_URL = "https://${config.paul.private.domains.authentik}/application/o/karakeep/.well-known/openid-configuration";
            OAUTH_PROVIDER_NAME = config.paul.private.misc.authentik_display_name;
            DISABLE_PASSWORD_AUTH = "true";
          };
          environmentFile = config.clan.core.vars.generators.karakeep.files.env.path;
        };

        # meilisearch breaks on every update (love it), this is just a hack to make it future paul's problem (you're welcome <3)
        services.meilisearch.package =
          assert pkgs.meilisearch.version == "1.18.0";
          pkgs.meilisearch;

        clan.core.vars.generators.karakeep = {
          prompts.oauth-client-id.description = "Karakeep OAuth2 Client ID";
          prompts.oauth-client-id.type = "hidden";
          prompts.oauth-client-id.persist = false;

          prompts.oauth-client-secret.description = "Karakeep OAuth2 Client Secret";
          prompts.oauth-client-secret.type = "hidden";
          prompts.oauth-client-secret.persist = false;

          prompts.openai-api-key.description = "Karakeep OpenAI API Key";
          prompts.openai-api-key.type = "hidden";
          prompts.openai-api-key.persist = false;

          files.env.secret = true;

          script = ''
            echo "\
            OAUTH_CLIENT_ID="$(cat $prompts/oauth-client-id)"
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

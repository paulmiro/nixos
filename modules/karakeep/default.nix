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

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        geo-ip = true;
      };
    };

    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString cfg.port;
        NEXTAUTH_URL = "https://${cfg.domain}";
        DISABLE_NEW_RELEASE_CHECK = "true";
        OAUTH_WELLKNOWN_URL = "https://${config.paul.private.domains.authentik}/application/o/karakeep/.well-known/openid-configuration";
        OAUTH_PROVIDER_NAME = config.paul.private.authentik_display_name;
        DISABLE_PASSWORD_AUTH = "true";
      };
      environmentFile = config.clan.core.vars.generators.karakeep.files.env.path;
    };

    # required because of state-version shenanigans
    # TODO: 25.11: remove this (assuming they actually removed meilisearch_1_11)
    services.meilisearch.package = pkgs.meilisearch;

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
  };
}

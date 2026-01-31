{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.outline;
in
{
  options.paul.outline = {
    enable = lib.mkEnableOption "enable outline server";
    enableNginx = lib.mkEnableOption "enable nginx reverse proxy for outline server";
    port = lib.mkOption {
      description = "internal port for outline server";
      type = lib.types.port;
      default = 19105;
    };
    domain = lib.mkOption {
      description = "domain for outline server";
      type = lib.types.str;
      default = "outline.${config.paul.private.domains.base}";
    };
  };

  config = lib.mkIf cfg.enable {

    services.outline = {
      enable = true;

      publicUrl = "https://${cfg.domain}";
      port = cfg.port;

      storage.storageType = "local";

      secretKeyFile = config.clan.core.vars.generators.outline.files.secret-key.path;
    };

    systemd.services.outline = {
      # to use PKCE, outline OIDC needs to be set up using OIDC_ISSUER_URL
      # the current version of the nixos module doesn't support setting the OIDC_ISSUER_URL, so we do this manually instead
      environment = {
        OIDC_CLIENT_ID = "outline";
        OIDC_ISSUER_URL = "https://${config.paul.private.domains.kanidm}/oauth2/openid/outline";
        OIDC_USERNAME_CLAIM = "preferred_username";
        OIDC_DISPLAY_NAME = config.paul.private.misc.kanidm_display_name;
        OIDC_SCOPES = "openid profile email";
        OIDC_DISABLE_REDIRECT = "true";
      };

      script = lib.mkBefore ''
        export OIDC_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg config.clan.core.vars.generators.outline.files.oidc-client-secret.path})"
      '';
    };

    clan.core.vars.generators.outline = {
      prompts.oidc-client-secret.description = "Outline OIDC Client Secret";
      prompts.oidc-client-secret.type = "hidden";
      prompts.oidc-client-secret.persist = false;

      files.secret-key.secret = true;
      files.secret-key.owner = "outline";
      files.secret-key.group = "outline";

      files.oidc-client-secret.secret = true;
      files.oidc-client-secret.owner = "outline";
      files.oidc-client-secret.group = "outline";

      runtimeInputs = [ pkgs.openssl ];

      script = ''
        openssl rand -hex 32 > $out/secret-key
        cp $prompts/oidc-client-secret $out/oidc-client-secret
      '';
    };

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        enableGeoIP = true;
      };
    };

  };
}

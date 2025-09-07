{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.gotify;
in
{
  options.paul.gotify = with lib; {
    enable = mkEnableOption "enable gotify server";

    enableNginx = mkEnableOption "enable nginx reverse proxy for gotify";
    port = mkOption {
      description = "internal port for gotify server";
      type = types.port;
      default = 34501;
    };
    domain = mkOption {
      description = "domain for gotify server";
      type = types.str;
      default = config.paul.private.domains.gotify;
    };
  };

  config = lib.mkIf cfg.enable {
    services.gotify = {
      enable = true;
      environment = {
        GOTIFY_SERVER_PORT = cfg.port;
        GOTIFY_DEFAULTUSER_NAME = "admin";
      };
      environmentFiles = [ config.clan.core.vars.generators.gotify.files.env.path ];
    };

    clan.core.vars.generators.gotify = {
      prompts.password.description = "Gotify Default User (admin) Password (see bw)";
      prompts.password.type = "hidden";
      prompts.password.persist = false;

      files.env.secret = true;

      script = ''
        echo "
        GOTIFY_DEFAULTUSER_PASS="$(cat $prompts/password)"
        " > $out/env
      '';
    };

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        geo-ip = false;
        proxyWebsockets = true;
      };
    };
  };
}

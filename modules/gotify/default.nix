{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.gotify;
  environmentFile = "/run/keys/gotify.env";
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
      default = "gotify.${config.paul.private.domains.base}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gotify = {
      enable = true;
      environment = {
        GOTIFY_SERVER_PORT = cfg.port;
      };
      environmentFiles = [ environmentFile ];
    };

    users.users.gotify-server = {
      uid = 63607;
      group = "gotify-server";
      isSystemUser = true;
      home = "/var/lib/${config.services.gotify.stateDirectoryName}";
      extraGroups = [ "keys" ];
    };

    users.groups.gotify-server = { };

    lollypops.secrets.files."gotify-env" = {
      cmd = ''
        echo "
        GOTIFY_DEFAULTUSER_NAME=admin
        GOTIFY_DEFAULTUSER_PASS="$(rbw get gotify-admin-password)"
        "'';
      path = environmentFile;
    };

    paul.dyndns.domains = lib.mkIf cfg.enableNginx [ cfg.domain ];

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        geo-ip = false;
        proxyWebsockets = true;
      };
    };
  };
}

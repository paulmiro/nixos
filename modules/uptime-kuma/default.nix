{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.uptime-kuma;
in
{
  options.paul.uptime-kuma = {
    enable = lib.mkEnableOption "activate uptime-kuma";

    enableNginx = lib.mkEnableOption "activate nginx for uptime-kuma";

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.uptime-kuma;
      description = "domain to run public uptime tracker under";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 19101; # 3001 by default, this is a random number
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      appriseSupport = true;
      settings = {
        PORT = toString cfg.port;
        HOST = "0.0.0.0";
      };
    };

    clan.core.state.uptime-kuma = {
      useZfsSnapshots = config.paul.zfs.enable;
      useRsyncCopy = !config.paul.zfs.enable;
      folders = [ "/var/lib/uptime-kuma" ];
      servicesToStop = [ "uptime-kuma.service" ];
    };

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        geo-ip = true;
        proxyWebsockets = true;
      };
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.audiobookshelf;
in
{
  options.paul.audiobookshelf = {
    enable = lib.mkEnableOption "activate audiobookshelf";
    openFirewall = lib.mkEnableOption "allow audiobookshelf port in firewall";
    enableNginx = lib.mkEnableOption "activate nginx proxy";

    port = lib.mkOption {
      type = lib.types.port;
      default = 13378;
      description = "Port to listen on";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.audiobookshelf;
      description = "domain name for audiobookshelf";
    };
  };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      inherit (cfg) port openFirewall;
      host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
    };

    clan.core.state.audiobookshelf = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/audiobookshelf" ];
      servicesToStop = [ "audiobookshelf.service" ];
    };

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyWebsockets = true;
        enableGeoIP = true;
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}

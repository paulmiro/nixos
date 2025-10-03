{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.jellyseerr;
in
{
  options.paul.jellyseerr = {
    enable = lib.mkEnableOption "activate jellyseerr";
    openFirewall = lib.mkEnableOption "allow jellyseerr port in firewall";
    enableNginx = lib.mkEnableOption "activate nginx proxy";
    enableDyndns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
      description = "Port to listen on";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.jellyseerr;
      description = "domain name for jellyseerr";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
      openFirewall = cfg.openFirewall;
    };

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = cfg.enableDyndns;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        geo-ip = true;
      };
    };
  };
}

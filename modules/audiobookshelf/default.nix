{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.audiobookshelf;
in
{
  options.paul.audiobookshelf = with lib; {
    enable = mkEnableOption "activate audiobookshelf";
    openFirewall = mkEnableOption "allow audiobookshelf port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 13378;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.audiobookshelf;
      description = "domain name for audiobookshelf";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.audiobookshelf = {
          enable = true;
          port = cfg.port;
          openFirewall = cfg.openFirewall;
          host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
        };

      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        paul.dyndns.domains = lib.mkIf cfg.enableDyndns [ cfg.domain ];

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            proxyWebsockets = true;
            geo-ip = true;
          };

        };
      })
    ]
  );
}

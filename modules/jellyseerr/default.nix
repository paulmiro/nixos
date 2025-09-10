{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.jellyseerr;
in
{
  options.paul.jellyseerr = with lib; {
    enable = mkEnableOption "activate jellyseerr";
    openFirewall = mkEnableOption "allow jellyseerr port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 5055;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.jellyseerr;
      description = "domain name for jellyseerr";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.sonarr.enable = true;
        paul.radarr.enable = true;

        services.jellyseerr = {
          enable = true;
          port = cfg.port;
          openFirewall = cfg.openFirewall;
          configDir = "/var/lib/jellyseerr"; # TODO remove when it's the default again (373533)
        };

      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = cfg.enableDyndns;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            geo-ip = true;
          };
        };
      })

    ]
  );
}

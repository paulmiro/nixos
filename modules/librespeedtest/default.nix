{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.librespeedtest;
in
{
  options.paul.librespeedtest = with lib; {
    enable = mkEnableOption "activate librespeedtest";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 5894;
      description = "port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.librespeedtest;
      description = "domain name for jellyfin";
    };

    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
      description = "title to display";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.docker.enable = true;

        virtualisation.oci-containers.containers.librespeedtest = {
          autoStart = true;
          image = "adolfintel/speedtest";
          environment = {
            TITLE = "${cfg.title}";
            ENABLE_ID_OBFUSCATION = "true";
            WEBPORT = builtins.toString cfg.port;
            MODE = "standalone";
          };
          ports = [ "${builtins.toString cfg.port}:${builtins.toString cfg.port}/tcp" ];
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

        systemd.services.docker-librespeedtest = {
          preStop = "${pkgs.docker}/bin/docker kill librespeedtest";
        };
      })

    ]
  );
}

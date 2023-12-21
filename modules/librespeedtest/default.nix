{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.librespeedtest;
in
{

  options.paul.librespeedtest = {
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
      default = "speedtest.pamiro.net";
      description = "domain name for jellyfin";
    };

    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
      description = "title to display";
    };
  };

  config = mkIf cfg.enable (mkMerge [
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

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
        };
        extraConfig = toString (
          optional config.paul.nginx.geoIP ''
            if ($allowed_country = no) {
                return 444;
            }
          ''
        );
      };
    })

  ]);

}

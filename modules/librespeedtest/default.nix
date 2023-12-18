{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.librespeedtest;
in
{

  options.paul.librespeedtest = {
    enable = mkEnableOption "activate librespeedtest";
    enableNginx = mkEnableOption "activate nginx proxy";

    port = mkOption {
      type = types.port;
      default = 5894;
      description = "port to listen on";

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

      services.nginx.virtualHosts."***REMOVED***" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
        };
        /*
      extraConfig = ''
        allow 131.220.0.0/16; # Uni-Netz
        deny all; # deny all remaining ips
      '';
        */
      };
    })

  ]);

}

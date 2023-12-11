{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.librespeedtest;
in
{

  options.paul.librespeedtest = {
    enable = mkEnableOption "activate librespeedtest";
    enableNginx = mkEnableOption "activate nginx proxy";

    port = mkOption {
      type = types.str;
      default = "5894";
      description = ''
        Documentation placeholder
      '';
    };
    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
      description = ''
        Documentation placeholder
      '';
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.librespeedtest = {
      autoStart = true;
      image = "adolfintel/speedtest";
      environment = {
        TITLE = "${cfg.title}";
        ENABLE_ID_OBFUSCATION = "true";
        WEBPORT = "${cfg.port}";
        MODE = "standalone";
      };
      ports = [ "${cfg.port}:${cfg.port}/tcp" ];
    };

    systemd.services.docker-librespeedtest = {
      preStop = "${pkgs.docker}/bin/docker kill librespeedtest";
    };

    services.nginx.virtualHosts."speedtest.pamiro.net" = mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.port}";
      };
      /*
      extraConfig = ''
        allow 131.220.0.0/16; # Uni-Netz
        deny all; # deny all remaining ips
      '';
      */
    };

  };
}

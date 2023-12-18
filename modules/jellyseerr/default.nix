{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.jellyseerr;
in
{

  options.paul.jellyseerr = {
    enable = mkEnableOption "activate jellyseerr";
    openFirewall = mkEnableOption "allow jellyseerr port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";

    port = mkOption {
      type = types.port;
      default = 5055;
      description = "Port to listen on";
    };

  };

  config = mkIf cfg.enable {
    paul.sonarr.enable = true;
    paul.radarr.enable = true;

    services.jellyseerr = {
      enable = true;
      port = cfg.port;
      openFirewall = cfg.openFirewall;
    };

    paul.nginx.enable = mkIf cfg.enableNginx true;

    services.nginx.virtualHosts."jellyseerr.pamiro.net" = mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
      };
    };
  };

}

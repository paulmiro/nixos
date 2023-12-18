{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.jellyseerr;
in
{

  options.paul.jellyseerr = {
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
      default = "jellyseerr.pamiro.net";
      description = "domain name for jellyseerr";
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

    paul.dyndns = mkIf cfg.enableDyndns {
      enable = true;
      domains = [ cfg.domain ];
    };

    services.nginx.virtualHosts."${cfg.domain}" = mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
      };
    };
  };

}

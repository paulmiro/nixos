{
  config,
  lib,

  private,
  ...
}:
let
  cfg = config.paul.seerr;
in
{
  options.paul.seerr = {
    enable = lib.mkEnableOption "activate seerr";
    openFirewall = lib.mkEnableOption "allow seerr port in firewall";
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
      default = private.domains.seerr;
      description = "domain name for seerr";
    };
  };

  config = lib.mkIf cfg.enable {
    services.seerr = {
      enable = true;
      port = cfg.port;
      openFirewall = cfg.openFirewall;
      configDir = "/var/lib/seerr";
    };

    clan.core.state.seerr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/private/seerr" ];
      servicesToStop = [ "seerr.service" ];
    };

    systemd.services.seerr.serviceConfig.StateDirectory = lib.mkForce "seerr";

    services.nginx.virtualHosts."${cfg.domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = cfg.enableDyndns;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        enableGeoIP = true;
      };
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.uptime-kuma;
in
{
  options.paul.uptime-kuma = with lib; {
    enable = mkEnableOption "activate uptime-kuma";

    enableNginx = mkEnableOption "activate nginx for uptime-kuma";

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.uptime-kuma;
      description = "domain to run public uptime tracker under";
    };

    openTailscaleFirewall = mkEnableOption "open the firewall for uptime-kuma";

    port = mkOption {
      type = types.port;
      default = 19101; # 3001 by default, this is a random number
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.uptime-kuma = {
          enable = true;
          appriseSupport = true;
          settings = {
            PORT = toString cfg.port;
            HOST = "0.0.0.0";
          };
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
          cfg.port
        ];
      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;
        paul.dyndns.domains = [ cfg.domain ];

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            geo-ip = true;
            proxyWebsockets = true;
          };
        };
      })

    ]
  );
}

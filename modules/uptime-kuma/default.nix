{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.uptime-kuma;
in
{
  options.paul.uptime-kuma = {
    enable = lib.mkEnableOption "activate uptime-kuma";

    enableNginx = lib.mkEnableOption "activate nginx for uptime-kuma";

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.uptime-kuma;
      description = "domain to run public uptime tracker under";
    };

    openTailscaleFirewall = lib.mkEnableOption "open the firewall for uptime-kuma";

    port = lib.mkOption {
      type = lib.types.port;
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

        clan.core.state.uptime-kuma = {
          useZfsSnapshots = config.paul.zfs.enable;
          useRsyncCopy = !config.paul.zfs.enable;
          folders = [ "/var/lib/uptime-kuma" ];
          servicesToStop = [ "uptime-kuma.service" ];
        };
      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = true;
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

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.hedgedoc;
in
{
  options.paul.hedgedoc = {
    enable = lib.mkEnableOption "enable hedgedoc";
    enableNginx = lib.mkEnableOption "enable nginx proxy for hedgedoc";
    openFirewall = lib.mkEnableOption "open firewall for hedgedoc";

    port = lib.mkOption {
      type = lib.types.port;
      default = 19103; # default would be 3000
      description = "port for hedgedoc";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.hedgedoc;
      description = "domain name for hedgedoc";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.hedgedoc = {
          enable = true;
          settings = {
            port = cfg.port;
            domain = lib.mkIf cfg.enableNginx cfg.domain;
            protocolUseSSL = cfg.enableNginx;
            # TODO: tn-migrate: set uploadsPath ?
            allowAnonymous = true;
            allowAnonymousEdits = true;
            allowFreeUrl = true;
            requireFreeURLAuthentication = true;
            defaultPermissions = "limited";
          };
        };
      }
      (lib.mkIf cfg.openFirewall {
        networking.firewall.allowedTCPPorts = [ cfg.port ];
      })
      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;
        paul.dyndns.domains = [ cfg.domain ];

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      })
    ]
  );
}

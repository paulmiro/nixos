{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.stirling-pdf;
in
{
  options.paul.stirling-pdf = {
    enable = lib.mkEnableOption "enable the Stirling PDF module";
    enableNginx = lib.mkEnableOption "enable nginx proxy for stirling-pdf";
    openFirewall = lib.mkEnableOption "open firewall for stirling-pdf";

    port = lib.mkOption {
      type = lib.types.port;
      default = 19102; # default is 8080, this is a random number
      description = "port for stirling-pdf";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.stirling-pdf;
      description = "domain name for stirling-pdf";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.stirling-pdf = {
          enable = true;
          environment = {
            SERVER_PORT = cfg.port;
            INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
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
          };
        };
      })
    ]
  );
}

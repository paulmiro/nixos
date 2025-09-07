{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.nginx;
in
{
  options.paul.nginx = with lib; {
    enable = mkEnableOption "activate nginx";

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "open port 80 and 443";
    };

    defaultDomain = mkOption {
      type = types.str;
      default = "${config.networking.hostName}.${config.paul.private.domains.base}";
      description = "The default domain to use for the nginx configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme.defaults.email = config.paul.private.emails.proton;
    security.acme.acceptTerms = true;

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      80
      443
    ];

    services.nginx = {
      enable = true;
      clientMaxBodySize = "8196m"; # 8GiB
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = lib.mkIf cfg.openFirewall ''
        map $scheme $hsts_header {
          https "max-age=31536000; includeSubdomains; -preload";
        }
        add_header Strict-Transport-Security $hsts_header;
      '';
      virtualHosts."${cfg.defaultDomain}" = {
        enableACME = lib.mkIf cfg.openFirewall true; # ACME fails with closed firewall
        forceSSL = lib.mkIf cfg.openFirewall true; # turn off SSL if we don't have a cert
        default = true;
        locations."/" = {
          return = "418"; # I'm a teapot
        };
      };
    };

    systemd.services.nginx = lib.mkIf config.paul.dyndns._enable {
      after = [
        "network.target"
        "cloudflare-dyndns.service"
      ];
      # Wait for 10 seconds to have the dns record up by the time the acme service runs
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
    };

    paul.dyndns = lib.mkIf cfg.openFirewall {
      # dyndns is pretty much useless without the opened ports
      extraDomains = [
        cfg.defaultDomain
        "*.${cfg.defaultDomain}"
      ];
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.nginx;
in
{

  options.paul.nginx = {
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

  config = mkIf cfg.enable {

    security.acme.defaults.email = config.paul.private.emails.proton;
    security.acme.acceptTerms = true;

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      80
      443
    ];

    services.nginx = {
      enable = true;
      clientMaxBodySize = "8196m"; # 8GiB
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = mkIf cfg.openFirewall ''
        map $scheme $hsts_header {
          https "max-age=31536000; includeSubdomains; -preload";
        }
        add_header Strict-Transport-Security $hsts_header;
      '';
      virtualHosts."${cfg.defaultDomain}" = {
        enableACME = mkIf cfg.openFirewall true; # ACME fails with closed firewall
        forceSSL = mkIf cfg.openFirewall true; # turn off SSL if we don't have a cert
        default = true;
        locations."/" = {
          return = "418"; # I'm a teapot
        };
      };
    };

    systemd.services.nginx = mkIf config.paul.dyndns.enable {
      after = [
        "network.target"
        "cloudflare-dyndns.service"
      ];
      # Wait for 10 seconds to have the dns record up by the time the acme service runs
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
    };

    paul.dyndns = mkIf cfg.openFirewall {
      # dyndns is pretty much useless without the opened ports
      enable = true;
      domains = [
        cfg.defaultDomain
        "*.${cfg.defaultDomain}"
      ];
    };
  };
}

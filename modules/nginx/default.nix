{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nginx;
in
{

  options.paul.nginx = {
    enable = mkEnableOption "activate nginx";
  };

  config = mkIf cfg.enable {

    security.acme.defaults.email = "***REMOVED***";
    security.acme.acceptTerms = true;

    services.nginx = {
      enable = true;
      clientMaxBodySize = "8196m";
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."***REMOVED***" = {
        enableACME = true;
        forceSSL = true;
        default = true;
        locations."/" = {
          return = "418"; # I'm a teapot
        };
      };
    };
    systemd.services.nginx.serviceConfig = mkIf config.paul.dyndns.enable {
      after = [ "cloudflare-dyndns.service" ];
    };
    paul.dyndns.domains = [ "***REMOVED***" ];
  };
}

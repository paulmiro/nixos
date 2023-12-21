{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nginx;
in
{

  options.paul.nginx = {
    enable = mkEnableOption "activate nginx";
  };

  config = mkIf cfg.enable {

    security.acme.defaults.email = "paul.mika.rohde@pm.me";
    security.acme.acceptTerms = true;

    services.nginx = {
      enable = true;
      clientMaxBodySize = "128m";
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."pamiro.net" = {
        enableACME = true;
        forceSSL = true;
        default = true;
        locations."/" = {
          return = "302 https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        };
      };
      virtualHosts."easteregg.pamiro.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "302 https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        };
      };
    };
    systemd.services.nginx.serviceConfig = mkIf config.paul.dyndns.enable {
      after = [ "cloudflare-dyndns.service" ];
    };
    paul.dyndns.domains = [ "pamiro.net" "easteregg.pamiro.net" ];
  };
}

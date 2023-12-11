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
      clientMaxBodySize = "128m";
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."***REMOVED***" = {
        enableACME = true;
        forceSSL = true;
        default = true;
        locations."/" = {
          return = "301 https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        };
      };
    };

  };
}

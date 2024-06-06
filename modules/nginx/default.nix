{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nginx;
in
{

  options.paul.nginx = {
    enable = mkEnableOption "activate nginx";
    defaultDomain = mkOption {
      type = types.str;
      default = "teapot.${builtins.readFile ../../secrets/domains/_base}";
      description = "The default domain to use for the nginx configuration";
    };
  };

  config = mkIf cfg.enable {

    security.acme.defaults.email = builtins.readFile ../../secrets/nginx-acme-email;
    security.acme.acceptTerms = true;

    services.nginx = {
      enable = true;
      clientMaxBodySize = "8196m"; # 8GiB
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${cfg.defaultDomain}" = {
        enableACME = true;
        forceSSL = true;
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
    paul.dyndns.domains = [ cfg.defaultDomain ];
  };
}

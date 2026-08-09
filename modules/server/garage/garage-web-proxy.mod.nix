{
  config,
  lib,
  pkgs,

  private,
  ...
}:
let
  cfg = config.paul.garage;
  domain = private.domains.garage-web;
  ports = import ./ports.nix;
in
{
  options.paul.garage = {
    enableWebProxy = lib.mkEnableOption "Garage Web Proxy";
  };

  config = lib.mkIf cfg.enableWebProxy {

    security.acme.certs.${domain} = {
      domain = domain;
      extraDomainNames = [ "*.${domain}" ];
      group = "nginx";
      dnsProvider = "cloudflare";
      environmentFile = config.clan.core.vars.generators.cloudflare-dyndns.files.env.path;
    };

    services.nginx.virtualHosts.${domain} = {
      serverAliases = [ "*.${domain}" ];
      enableACME = false;
      useACMEHost = domain;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://turing.${private.domains.tailnet}:${toString ports.web}";
        enableGeoIP = true;
      };
    };

    assertions = [
      {
        assertion = !cfg.enable;
        message = "garage-web-proxy must run on a different machine than garage";
      }
    ];
  };
}

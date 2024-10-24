{ lib, config, ... }:
with lib; let
  vhostOptions = { config, ... }: {
    options = {
      enableWWWSubdomain = mkEnableOption "enable www subdomain";
    };
  };
in
{
  options = {
    services.nginx.virtualHosts = with types;
      mkOption {
        type = types.attrsOf (types.submodule vhostOptions);
      };
  };
  config =
    (map
      (domain:
        let
          originalVirtualHost = config.services.nginx.virtualHosts."${domain}";
        in
        {
          services.nginx.virtualHosts."www.${domain}" = {
            useACMEHost = mkIf originalVirtualHost.enableACME domain;
            forceSSL = originalVirtualHost.forceSSL;
            globalRedirect = domain;
          };
          security.acme.certs."${domain}".extraDomainNames = mkIf originalVirtualHost.enableACME [
            "www.${domain}"
          ];

        })
      (builtins.filter (domain: !lib.strings.hasPrefix "www.")
        (builtins.filter
          (domain: config.services.nginx.virtualHosts."${domain}".enableWWWSubdomain)
          (builtins.attrNames config.services.nginx.virtualHosts)
        )
      )
    );
}

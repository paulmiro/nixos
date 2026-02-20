{
  config,
  lib,
  useful-api,
  ...
}:
let
  cfg = config.paul.useful-api;
  port = 19109;
in
{
  imports = [
    useful-api.nixosModules.useful-api-auto-update
  ];

  options.paul.useful-api = {
    enable = lib.mkEnableOption "enable useful-api";
  };

  config = lib.mkIf cfg.enable {
    # TODO remove later
    services.nginx.virtualHosts."api.${config.paul.private.domains.base}" = {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };

    services.nginx.virtualHosts."useful-api.party" = {
      # enableACME = true;
      # forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };

    services.useful-api = {
      enable = true;
      inherit port;
    };
  };
}

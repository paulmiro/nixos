{
  config,
  lib,

  inputs,
  private,
  ...
}:
let
  cfg = config.paul.useful-api;
  port = 19109;
  bindAddress = "127.0.0.1";
in
{
  imports = [
    inputs.useful-api.nixosModules.useful-api-auto-update
  ];

  options.paul.useful-api = {
    enable = lib.mkEnableOption "enable useful-api";
  };

  config = lib.mkIf cfg.enable {
    # TODO remove later
    services.nginx.virtualHosts."api.${private.domains.base}" = {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        return = "301 https://useful-api.party$request_uri";
      };
    };

    services.nginx.virtualHosts."useful-api.party" = {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };

    services.useful-api = {
      enable = true;
      inherit port;
      inherit bindAddress;
    };
  };
}

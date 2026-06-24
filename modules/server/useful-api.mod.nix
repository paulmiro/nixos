{
  config,
  lib,

  inputs,
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

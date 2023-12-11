{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.jellyfin;
in
{

  options.paul.jellyfin = {
    enable = mkEnableOption "activate jellyifn";
    enableNginx = mkEnableOption "activate nginx proxy";
  };

  config = mkIf cfg.enable {

    services.nginx.virtualHosts."jellyfin.pamiro.net" = mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };

  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.sso;
in
{

  options.paul.sso = {
    enable = mkEnableOption "activate sso-stack";

    keycloak = {
      openFirewall = mkEnableOption "allow keycloak port in firewall";
      enableNginx = mkEnableOption "activate nginx proxy";
    };
  };

  config = mkIf cfg.enable {
    paul.keycloak = {
      enable = true;
      openFirewall = cfg.keycloak.openFirewall;
      enableNginx = cfg.keycloak.enableNginx;
    };

  };

}



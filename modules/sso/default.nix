{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.sso;
in
{

  options.paul.sso = {
    enable = mkEnableOption "activate sso-stack";

    baseDomain = mkOption {
      type = types.str;
      default = "kiste.dev";
      description = "The base domain for the sso stack";
    };

    subDomain = mkOption {
      type = types.str;
      default = "auth";
      description = "The subdomain for the sso stack";
    };

    keycloak = {
      openFirewall = mkEnableOption "allow keycloak port in firewall";
      enableNginx = mkEnableOption "activate nginx proxy";
    };

    # TODO: Does this option even make sense?
    oauth2-proxy = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "activate oauth2-proxy";
      };
    };
  };

  config = mkIf cfg.enable {
    paul.keycloak = {
      enable = true;
      openFirewall = cfg.keycloak.openFirewall;
      enableNginx = cfg.keycloak.enableNginx;
      domain = "${cfg.subDomain}.${cfg.baseDomain}";
    };

    paul.oauth2-proxy = {
      enable = cfg.oauth2-proxy.enable;
      domain = "${cfg.subDomain}.${cfg.baseDomain}";
      baseDomain = cfg.baseDomain;
    };

    paul.openldap = {
      enable = true;
    };

  };

}



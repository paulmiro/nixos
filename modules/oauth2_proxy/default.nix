{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.oauth2-proxy;
in
{

  # for now, simply add
  #
  # services.oauth2-proxy.nginx.virtualHosts."${cfg.domain}" = {
  #   allowed_groups = [ cfg.allowedGroup ];
  # };
  #
  # to the config of the module that should be protected by the oauth2 proxy

  # TODO: create a nice way to have this as part of the nginx config, like with geo-ip

  options.paul.oauth2-proxy = {

    enable = mkEnableOption "activate oauth2-proxy";

    domain = mkOption {
      type = types.str;
      default = "auth.${config.paul.private.domains.base}";
      description = "The domain to use for the oauth2 proxy";
    };

    baseDomain = mkOption {
      type = types.str;
      default = config.paul.private.domains.base;
      description = "The base domain to use for the oauth2 proxy";
    };

    keyFile = mkOption {
      type = types.str;
      default = "/run/keys/oauth2-proxy-keys";
      description = "The path to the file containing the oauth2 proxy keys";
    };

  };

  config = mkIf cfg.enable {

    services.oauth2-proxy = {

      # https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/keycloak_oidc/

      enable = true;
      reverseProxy = true;
      setXauthrequest = true;
      provider = "keycloak-oidc";
      scope = "openid";
      email.domains = [ "*" ];

      # important:
      # needs audience mapper!
      # https://github.com/oauth2-proxy/oauth2-proxy/issues/1931#issuecomment-1374875310
      clientID = "oauth2-proxy";
      cookie.domain = ".${cfg.baseDomain}";
      cookie.expire = "336h0m0s";

      extraConfig = {
        session-cookie-minimal = "true";
        whitelist-domain = "*.${cfg.baseDomain}";
        oidc-issuer-url = "https://${cfg.domain}/realms/master";
        # allowed-group = "admins"; # setting this breaks per-vhost allowed_groups
      };

      keyFile = cfg.keyFile;

      #nginx.virtualHosts = cfg.virtualHosts;
      nginx.domain = cfg.domain;

    };

    # start oauth2-proxy after Keycloak is up
    # otherwise it will fail to start because it can't resolve the keycloak host
    systemd.services.oauth2-proxy = {
      after = [
        "network.target"
        (mkIf config.services.keycloak.enable "keycloak.service")
      ];
      serviceConfig = {
        # I assume this is to wait for keycloak to finish starting up
        ExecStartPre = mkIf config.services.keycloak.enable "${pkgs.coreutils}/bin/sleep 10";
      };
    };

    lollypops.secrets.files."oauth2-proxy-keys" = {
      # it's... beautiful
      cmd = ''
        echo "
        OAUTH2_PROXY_CLIENT_SECRET=$(rbw get oauth2-proxy-client-secret)
        OAUTH2_PROXY_COOKIE_SECRET=$(rbw get oauth2-proxy-cookie-secret)
        "'';
      path = cfg.keyFile;
    };
  };
}

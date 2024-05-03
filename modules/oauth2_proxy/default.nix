{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.oauth2_proxy;
in
{

  # for now, simply add
  # paul.oauth2_proxy.virtualHosts = [ cfg.domain ];
  # to the config of the module that should be protected by the oauth2 proxy

  # TODO: create a nice way to have this as part of the nginx config, like with geo-ip

  options.paul.oauth2_proxy = {

    enable = mkEnableOption "activate oauth2_proxy";

    virtualHosts = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "A list of nginx virtual hosts to put behind the oauth2 proxy";
    };

    domain = mkOption {
      type = types.str;
      default = "***REMOVED***";
      description = "The domain to use for the oauth2 proxy";
    };

    baseDomain = mkOption {
      type = types.str;
      default = "***REMOVED***";
      description = "The base domain to use for the oauth2 proxy";
    };

    keysFilePath = mkOption {
      type = types.str;
      default = "/run/keys/oauth2_proxy-keys";
      description = "The path to the file containing the oauth2 proxy keys";
    };

  };

  config = mkIf cfg.enable {

    services.oauth2_proxy = {

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
      clientID = "oauth2_proxy";
      cookie.domain = ".${cfg.baseDomain}";
      cookie.expire = "336h0m0s";

      extraConfig = {
        session-cookie-minimal = "true";
        whitelist-domain = "*.${cfg.baseDomain}";
        oidc-issuer-url = "https://${cfg.domain}/realms/master";
        allowed-group = "admins";
      };

      keyFile = cfg.keysFilePath;

      nginx.virtualHosts = cfg.virtualHosts;
      nginx.domain = cfg.domain;

    };

    # start oauth2_proxy after Keycloak is up
    # otherwise it will fail to start because it can't resolve the keycloak host
    systemd.services.oauth2_proxy = {
      after = [
        "network.target"
        (mkIf config.services.keycloak.enable "keycloak.service")
      ];
      serviceConfig = {
        # I assume this is to wait for keycloak to finish starting up
        ExecStartPre = mkIf config.services.keycloak.enable "${pkgs.coreutils}/bin/sleep 10";
      };
    };

    lollypops.secrets.files."oauth2_proxy-keys" = {
      # it's... beautiful
      cmd = "echo \"OAUTH2_PROXY_CLIENT_SECRET=$(rbw get keycloak --field=oauth2_proxy-client-secret)\nOAUTH2_PROXY_COOKIE_SECRET=$(rbw get keycloak --field=oauth2_proxy-cookie-secret)\"";
      path = cfg.keysFilePath;
    };
  };
}

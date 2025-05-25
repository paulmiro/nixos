{
  config,
  lib,
  ...
}:
let
  global-config = config;
in
let
  vhostOptions =
    { config, ... }:
    {
      options = {
        enableAuthentik = lib.mkEnableOption "Enable Authentik Proxy";
      };
      config = lib.mkIf config.enableAuthentik {
        locations."/".extraConfig = ''
          auth_request     /outpost.goauthentik.io/auth/nginx;
          error_page       401 = @goauthentik_proxy_signin;
          auth_request_set $auth_cookie $upstream_http_set_cookie;
          add_header       Set-Cookie $auth_cookie;

          # translate headers from the outposts back to the actual upstream
          auth_request_set $authentik_username $upstream_http_x_authentik_username;
          auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
          auth_request_set $authentik_email $upstream_http_x_authentik_email;
          auth_request_set $authentik_name $upstream_http_x_authentik_name;
          auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

          proxy_set_header X-authentik-username $authentik_username;
          proxy_set_header X-authentik-groups $authentik_groups;
          proxy_set_header X-authentik-email $authentik_email;
          proxy_set_header X-authentik-name $authentik_name;
          proxy_set_header X-authentik-uid $authentik_uid;
        '';
        locations."/outpost.goauthentik.io".extraConfig = ''
          proxy_pass              https://${global-config.paul.private.domains.authentik}:9443/outpost.goauthentik.io;
          # ensure the host of this vserver matches your external URL you've configured in authentik
          # and ensure that port 9443 is open to the public
          proxy_set_header        Host $host;
          proxy_set_header        X-Original-URL $scheme://$http_host$request_uri;
          add_header              Set-Cookie $auth_cookie;
          auth_request_set        $auth_cookie $upstream_http_set_cookie;
          proxy_pass_request_body off;
          proxy_set_header        Content-Length "";
        '';
        locations."@goauthentik_proxy_signin".extraConfig = ''
          # Special location for when the /auth endpoint returns a 401,
          # redirect to the /start URL which initiates SSO
          internal;
          add_header Set-Cookie $auth_cookie;
          return 302 /outpost.goauthentik.io/start?rd=$request_uri;
          # For domain level, use the below error_page to redirect to your authentik server with the full redirect path
          # return 302 https://${global-config.paul.private.domains.authentik}/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
        '';
      };
    };
in
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };
}

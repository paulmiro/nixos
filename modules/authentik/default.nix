{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.paul.authentik;
  vhostOptions = { config, ... }: {
    options = {
      enableAuthentik = lib.mkEnableOption "Enable Authentik Proxy"; # TODO: this currently doesn't work causes tons of 500 errors in the NGINX log
    };
    config =
      lib.mkIf config.enableAuthentik {
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
          proxy_pass              https://***REMOVED***/outpost.goauthentik.io;
          # ensure the host of this vserver matches your external URL you've configured
          # in authentik
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
          # return 302 https://***REMOVED***/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
        '';
      };
  };
in
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };

  options.paul.authentik = {
    enable = mkEnableOption "activate authentik";
    openFirewall = mkEnableOption "open firewall for authentik";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 9100;
      description = "port to listen on for http";
    };

    httpsPort = mkOption {
      type = types.port;
      default = 9443;
      description = "port to listen on for https";
    };

    domain = mkOption {
      type = types.str;
      default = "***REMOVED***";
      description = "domain name for authentik";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      paul.nfs-mounts = {
        enableAuthentik = true;
      };

      systemd.services.docker-authentik = {
        description = "Authentik docker-compose service";
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
          "mnt-nfs-authentik.mount"
          "remote-fs.target"
        ];
        serviceConfig = {
          WorkingDirectory = "${./compose}";
          ExecStart = "${pkgs.docker}/bin/docker compose up --build";
          Restart = "on-failure";
        };
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port cfg.httpsPort ];
    }

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx = {
        virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://authentik";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade_keepalive;
            '';
          };
          enableGeoBlocking = true;
        };
        appendHttpConfig = ''
          upstream authentik {
              server 127.0.0.1:${toString cfg.port};
              # Improve performance by keeping some connections alive.
              keepalive 10;
          }
          map $http_upgrade $connection_upgrade_keepalive {
              default upgrade;
              '''      ''';
          }
        '';
      };
    })

  ]);

}

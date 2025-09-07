{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.jellyseerr;
in
{
  options.paul.jellyseerr = with lib; {
    enable = mkEnableOption "activate jellyseerr";
    openFirewall = mkEnableOption "allow jellyseerr port in firewall";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 5055;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.jellyseerr;
      description = "domain name for jellyseerr";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.sonarr.enable = true;
        paul.radarr.enable = true;

        services.jellyseerr = {
          enable = true;
          port = cfg.port;
          openFirewall = cfg.openFirewall;
          configDir = "/var/lib/jellyseerr"; # TODO remove when it's the default again (373533)
        };

      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = cfg.enableDyndns;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            geo-ip = true;
          };
        };

        # TODO: remove (changed from 301 to 410 on 2025-05-06)
        services.nginx.virtualHosts."${config.paul.private.domains.jellyseerr_old}" =
          let
            web-root-dir = pkgs.writeTextFile {
              name = "web-root";
              text = ''
                <!DOCTYPE html>
                <html>
                <head><meta charset="utf-8"/></head>
                <body style="font-family: sans-serif; color: #ddd; background-color: #111">
                  <div style="text-align: center; margin-top: 20%">
                    <p style="font-size: 5em; margin: 0">🚧</p>
                    <h1>Page has been moved</h1>
                    <p>The page you are looking for is now accessible at <a style="color: #a75ebd" href="https://${cfg.domain}">${cfg.domain}</a></p>
                    <p>Please update your bookmarks.</p>
                    <p style="font-size: 5em; margin: 0">🚧</p>
                  </div>
                </body>
                </html>
              '';
              destination = "/errors/410.html";
            };
          in
          {
            enableACME = true;
            forceSSL = true;
            enableDyndns = cfg.enableDyndns;
            root = "${web-root-dir}";
            extraConfig = ''
              error_page 410 /errors/410.html;
            '';
            locations."/" = {
              return = "410";
            };
            locations."/errors/" = {
              root = "${web-root-dir}";
            };
          };
      })

    ]
  );
}

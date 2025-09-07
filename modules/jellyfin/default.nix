{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.jellyfin;
in
{
  options.paul.jellyfin = with lib; {
    enable = mkEnableOption "activate jellyfin";
    containerVersion = mkOption {
      type = types.str;
      default = "10.10.7";
      description = "jellyfin version";
    };

    openFirewall = mkEnableOption "open firewall for jellyfin";

    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.jellyfin;
      description = "domain name for jellyfin";
    };

    enableQuickSync = mkEnableOption "enable quicksync";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.nfs-mounts = {
          enableJellyfin = true;
          enableArr = true;
        };

        /*
          // This needs some really complicated migration
          // https://jellyfin.org/docs/general/administration/migrate/
          // the script only works on windows, so this will propably be way too much work to be worth it

          services.jellyfin = {
            enable = true;
            dataDir = "/mnt/nfs/jellyfin";
            openFirewall = cfg.openFirewall;
          };

          users.users."jellyfin".uid = 4001;
          users.groups."jellyfin".gid = 4001;

          systemd.services.jellyfin = {
            after = [
              "mnt-nfs-arr.mount"
              "mnt-nfs-jellyfin.mount"
              "remote-fs.target"
            ];
          };
        */

        virtualisation.oci-containers.backend = "docker";
        virtualisation.oci-containers.containers.jellyfin = {
          image = "jellyfin/jellyfin:${cfg.containerVersion}";
          user = "4001:4001";
          volumes = [
            "/mnt/nfs/jellyfin/config:/config"
            "/mnt/nfs/jellyfin/cache:/cache"
            "/mnt/nfs/arr/media:/data/media:ro"
          ];
          extraOptions = [
            "--network=host"
          ]
          ++ lib.optionals (cfg.enableQuickSync) [
            # get group ID with: `getent group render | cut -d: -f3`
            "--group-add=303"
            "--device=/dev/dri/renderD128:/dev/dri/renderD128"
          ]
          ++ lib.optionals (config.paul.nvidia.enable) [
            "--gpus"
            "all"
          ];
        };

        systemd.services.docker-jellyfin = {
          after = [
            "mnt-nfs-arr.mount"
            "mnt-nfs-jellyfin.mount"
            "remote-fs.target"
          ];
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 8096 ];
      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = cfg.enableDyndns;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            geo-ip = true;
            proxyWebsockets = true;
          };
        };

        # TODO: remove (changed from proxy to 410 on 2025-05-06)
        services.nginx.virtualHosts."${config.paul.private.domains.jellyfin_old}" =
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
                    <div sty>
                    <p>The page you are looking for is now accessible at <a style="color: #a75ebd" href="https://${cfg.domain}">${cfg.domain}</a></p>
                    <p>Please update your bookmarks and edit the domain in mobile and TV apps.</p>
                    <p>If you need help setting up the apps you know who to call :)</p>
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

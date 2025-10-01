{
  config,
  lib,
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
        paul.docker.enable = true;

        virtualisation.oci-containers.containers.jellyfin = {
          image = "jellyfin/jellyfin:${cfg.containerVersion}";
          volumes = [
            "/var/lib/jellyfin/config:/config"
            "/var/lib/jellyfin/cache:/cache"
            "/mnt/arr/media:/data/media:ro"
          ];
          extraOptions = [
            "--network=host"
          ]
          ++ lib.optionals (cfg.enableQuickSync) [
            # get group ID with: `getent group render | cut -d: -f3`
            "--group-add=303"
            "--device=/dev/dri/renderD129:/dev/dri/renderD129"
          ]
          ++ lib.optionals (config.paul.nvidia.enable) [
            "--gpus"
            "all"
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
      })

    ]
  );
}

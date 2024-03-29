{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.immich;
in
{

  options.paul.immich = {
    enable = mkEnableOption "activate immich";
    openFirewall = mkEnableOption "open firewall for immich";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 2283;
      description = "port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "immich.pamiro.net";
      description = "domain name for immich";
    };

    # enableQuickSync = mkEnableOption "enable quicksync";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      paul.nfs-mounts = {
        enableImmich = true;
        enablePhotos = true;
      };

      systemd.services.docker-immich = {
        description = "Immich docker-compose service";
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
          "mnt-nfs-photos.mount"
          "mnt-nfs-immich.mount"
          "remote-fs.target"
        ];
        serviceConfig = {
          WorkingDirectory = "${./compose}";
          ExecStart = "${pkgs.docker}/bin/docker compose up --build";
          Restart = "on-failure";
        };
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    }

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          geo-ip = true;
        };
      };
    })

  ]);

}

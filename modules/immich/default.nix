{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.immich;
in
{
  options.paul.immich = with lib; {
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
      default = config.paul.private.domains.immich;
      description = "domain name for immich";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/run/keys/immich.env";
      description = "path to the secrets environment file";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.nfs-mounts = {
          enableImmich = true;
          enablePhotos = true;
        };
        paul.docker.enable = true;

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
            ExecStart = "${pkgs.docker}/bin/docker compose --env-file .env --env-file ${cfg.environmentFile} up --build";
            ExecStop = "${pkgs.docker}/bin/docker compose down";
            Restart = "on-failure";
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

        lollypops.secrets.files."immich-environment" = {
          cmd = ''
            echo "
            DB_PASSWORD="$(rbw get immich-database-password)"
            "'';
          path = cfg.environmentFile;
        };
      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;
        paul.dyndns.domains = lib.mkIf cfg.enableDyndns [ cfg.domain ];

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            geo-ip = true;
            proxyWebsockets = true;
          };
        };
      })

    ]
  );
}

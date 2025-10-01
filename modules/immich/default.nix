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
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.docker.enable = true;

        systemd.services.immich-docker-compose = {
          description = "Immich docker-compose service";
          wantedBy = [ "multi-user.target" ];
          after = [
            "docker.service"
            "docker.socket"
          ];
          serviceConfig = {
            WorkingDirectory = "${./compose}";

            ExecStart =
              let
                envFile = config.clan.core.vars.generators.immich.files.env.path;
              in
              "${pkgs.docker}/bin/docker compose --env-file .env --env-file ${envFile} up --build";
            ExecStop = "${pkgs.docker}/bin/docker compose down";
            Restart = "on-failure";
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

        clan.core.vars.generators.immich = {
          prompts.database-password.description = "Immich Internal Database Password (see bw)";
          prompts.database-password.type = "hidden";
          prompts.database-password.persist = false;

          files.env.secret = true;
          files.env.owner = "root"; # TODO: make immich run under a different user?

          script = ''
            echo "
            DB_PASSWORD="$(cat $prompts/database-password)"
            " > $out/env
          '';
        };
      }

      (lib.mkIf cfg.enableNginx {
        paul.nginx.enable = true;

        services.nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          enableDyndns = cfg.enableDyndns;
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

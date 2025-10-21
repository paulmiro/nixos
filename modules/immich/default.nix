{
  config,
  lib,
  pkgs,
  immich-source,
  ...
}:
let
  cfg = config.paul.immich;
  version = (builtins.fromJSON (builtins.readFile "${immich-source}/server/package.json")).version;
  versionEnvFile =
    assert lib.strings.hasPrefix "2." version; # should only fail on major version releases
    pkgs.writeText "immich-version.env" ''
      IMMICH_VERSION=v${version}
    '';
  serviceName = "immich-docker-compose";
in
{
  options.paul.immich = {
    enable = lib.mkEnableOption "activate immich";
    openFirewall = lib.mkEnableOption "open firewall for immich";
    enableNginx = lib.mkEnableOption "activate nginx proxy";
    enableDyndns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = "port to listen on";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.paul.private.domains.immich;
      description = "domain name for immich";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        paul.docker.enable = true;

        systemd.services.${serviceName} = {
          description = "Immich docker-compose service";
          wantedBy = [ "multi-user.target" ];
          after = [
            "docker.service"
            "docker.socket"
          ]
          ++ lib.optionals (config.paul.zfs.enable) [
            "zfs.target"
          ];
          serviceConfig = {
            WorkingDirectory = "${./compose}";

            ExecStart =
              let
                envFile = config.clan.core.vars.generators.immich.files.env.path;
              in
              "${pkgs.docker}/bin/docker compose --env-file .env --env-file ${envFile} --env-file ${versionEnvFile} up --build";
            ExecStop = "${pkgs.docker}/bin/docker compose down";
            Restart = "on-failure";
          };
        };

        environment.etc."immich/version.env" = {
          source = versionEnvFile;
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

        clan.core.state.immich = {
          useZfsSnapshots = true;
          folders = [
            "/var/lib/immich"
            "/mnt/photos"
          ];
          servicesToStop = [ "${serviceName}.service" ];
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

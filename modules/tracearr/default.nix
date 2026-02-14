{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.tracearr;
  version = "1.4.17";
  serviceName = "tracearr-docker-compose";
  port = 19110;
in
{
  options.paul.tracearr = {
    enable = lib.mkEnableOption "activate tracearr";
    enableTailscaleService = lib.mkEnableOption "use tailscale serve to proxy tracearr";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    systemd.services.${serviceName} = {
      description = "Tracearr docker-compose service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "docker.service"
        "docker.socket"
      ];
      serviceConfig = {
        WorkingDirectory = "${./compose}";

        ExecStart =
          let
            envFile = pkgs.writeText "tracearr.env" ''
              DATA_DIR=/var/lib/tracearr

              TRACEARR_VERSION=v${version}
              PORT=${toString port}
              TZ=${config.time.timeZone}
              # LOG_LEVEL=info # (debug, info, warn, error)
            '';
            secretsEnvFile = config.clan.core.vars.generators.tracearr.files.env.path;
          in
          "${pkgs.docker}/bin/docker compose --env-file ${envFile} --env-file ${secretsEnvFile} up --build";
        ExecStop = "${pkgs.docker}/bin/docker compose down";
        Restart = "on-failure";
      };
    };

    # tracearr does some weird uid/gid stuff internally
    systemd.tmpfiles.rules = [
      "d /var/lib/tracearr            0700  root  root - -"
      "d /var/lib/tracearr/redis      0755  999   root - -"
      "d /var/lib/tracearr/timescale  0700  1000  1000 - -"
    ];

    clan.core.vars.generators.tracearr = {
      files.env.secret = true;

      runtimeInputs = [ pkgs.openssl ];

      script = ''
        echo "JWT_SECRET=$(openssl rand -hex 32)" > $out/env
        echo "DB_PASSWORD=$(openssl rand -hex 32)" >> $out/env
        echo "COOKIE_SECRET=$(openssl rand -hex 32)" >> $out/env
      '';
    };

    paul.tailscale.services.tracearr.port = lib.mkIf cfg.enableTailscaleService port;

    clan.core.state.tracearr = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/tracearr"
      ];
      servicesToStop = [ "${serviceName}.service" ];
    };
  };
}

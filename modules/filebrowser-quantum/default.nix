{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.filebrowser-quantum;
  serviceName = "filebrowser-quantum";
  configFile = pkgs.writeText "config.yaml" (lib.generators.toYAML { } cfg.config);
in
{
  options.paul.filebrowser-quantum = {
    enable = lib.mkEnableOption "activate filebrowser";
    enableNginx = lib.mkEnableOption "activate nginx proxy for filebrowser-quantum";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The filebrowser-quantum package to use.";
      # current version in nixpkgs is out of date
      default = pkgs.callPackage ./package.nix { };
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra groups to add to filebrowser-quantum user.";
    };

    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "filebrowser-quantum config";
    };
  };

  config = lib.mkIf cfg.enable {
    paul.filebrowser-quantum.config = {
      server = {
        externalUrl = "https://${config.paul.private.domains.filebrowser-quantum}";
        port = 19111;

        cacheDir = "/var/cache/filebrowser-quantum";
        database = "database.db";

        sources = [
          {
            name = "Arr";
            path = "/mnt/arr";
          }
        ];
      };

      integrations = {
        media = {
          ffmpegPath = "${pkgs.ffmpeg}/bin";
          extractEmbeddedSubtitles = false;
        };
      };
    };

    users.users.filebrowser-quantum = {
      description = "Filebrowser Quantum";
      isSystemUser = true;
      group = "filebrowser-quantum";
      extraGroups = lib.mkIf config.paul.group.transmission.enable [
        config.users.groups.transmission.name
      ];
    };

    users.groups.filebrowser-quantum = { };

    systemd.services.${serviceName} = {
      description = "FileBrowser Quantum";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = config.users.users.filebrowser-quantum.name;
        Group = config.users.groups.filebrowser-quantum.name;
        CacheDirectory = "filebrowser-quantum";
        StateDirectory = "filebrowser-quantum";
        WorkingDirectory = "/var/lib/filebrowser-quantum";
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";

        EnvironmentFile = config.clan.core.vars.generators.filebrowser-quantum.files.env.path;

        Restart = "on-failure";
        RestartSec = "10s";

        ReadOnlyDirectories = map (
          source: source.path
        ) config.paul.filebrowser-quantum.config.server.sources;

        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = "disconnected";
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
    };

    clan.core.vars.generators.filebrowser-quantum = {
      prompts.admin-password.description = "filebrowser-quantum Admin Password (see bw)";
      prompts.admin-password.type = "hidden";
      prompts.admin-password.persist = false;

      files.env.secret = true;

      script = ''
        echo "
        FILEBROWSER_ADMIN_PASSWORD="$(cat $prompts/admin-password)"
        " > $out/env
      '';
    };

    clan.core.state.filebrowser-quantum = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/filebrowser-quantum"
      ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    services.nginx.virtualHosts."${config.paul.private.domains.filebrowser-quantum}" =
      lib.mkIf cfg.enableNginx
        {
          enableACME = true;
          forceSSL = true;
          enableDyndns = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.config.server.port}";
            enableGeoIP = true;
            proxyWebsockets = true;
          };
        };
  };

}

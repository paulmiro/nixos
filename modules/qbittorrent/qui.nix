{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.qbittorrent.qui;
  port = 7476;
  serviceName = "qui";
in
{
  options.paul.qbittorrent.qui = {
    enable = lib.mkEnableOption "activate qui (alternative frontend for qbittorrent)";
    configDir = lib.mkOption {
      description = "config directory for qui";
      type = lib.types.path;
      default = "/var/lib/qui";
    };
    enableTailscaleService = lib.mkEnableOption "enable tailscale service for qui";
  };

  config = lib.mkIf cfg.enable {

    paul.user.transmission.enable = true;

    systemd.services.qui-generate-config = {
      serviceConfig = {
        Type = "oneshot";
        # this skips generation if the file already exists, so we can safely run it on every boot
        ExecStart = "${lib.getExe pkgs.qui} generate-config --config-dir /var/lib/qui";

        StateDirectory = "qui";

        User = "transmission";
        Group = "transmission";
      };
    };

    systemd.services.${serviceName} = {
      description = "qui qBittorrent frontend";
      after = [
        "network.target"
        "qui-generate-config.service"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.qui} serve --config-dir /var/lib/qui";

        StateDirectory = "qui";

        User = "transmission";
        Group = "transmission";

        Restart = "on-failure";

        PrivateNetwork = false;
        RemoveIPC = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHome = "yes";
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectSystem = "full";
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
        SystemCallFilter = [ "@system-service" ];
      };
    };

    paul.tailscale.services.qui.port = lib.mkIf cfg.enableTailscaleService port;

    clan.core.state.qbittorrent = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/qui" ];
      servicesToStop = [ "${serviceName}.service" ];
    };
  };
}

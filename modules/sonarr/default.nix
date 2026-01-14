{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.sonarr;
  port = config.services.sonarr.settings.server.port;
in
{
  options.paul.sonarr = {
    enable = lib.mkEnableOption "activate sonarr";
    enableTailscaleService = lib.mkEnableOption "use tailscale serve to proxy sonarr";
  };

  config = lib.mkIf cfg.enable {
    paul.group.transmission.enable = true;

    services.sonarr = {
      enable = true;
      group = "transmission";
    };

    # HACK: sonarr sometimes becomes unresponsive, so we restart it
    systemd.services.sonarr-restarter = {
      description = "Restart sonarr when it becomes unresponsive";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "60s";
        ExecStart = "${lib.getExe (
          pkgs.writeShellScriptBin "sonarr-restarter-script" ''
            if ${lib.getExe pkgs.curl} localhost:${toString port}/ping --max-time 5 > /dev/null 2>&1; then
              echo "Sonarr is responding normally, not restarting it..."
              exit 0
            fi
            echo "Sonarr is unresponsive, restarting it..."
            ${pkgs.systemd}/bin/systemctl restart sonarr
            echo $(date) >> /var/lib/sonarr/restarter.log
          ''
        )}";
      };
    };

    paul.tailscale.services.sonarr.port = lib.mkIf cfg.enableTailscaleService port;

    clan.core.state.sonarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/sonarr" ];
      servicesToStop = [ "sonarr.service" ];
    };
  };
}

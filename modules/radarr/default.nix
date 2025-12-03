{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.radarr;
  port = config.services.radarr.settings.server.port;
in
{
  options.paul.radarr = {
    enable = lib.mkEnableOption "activate radarr";
    enableTailscaleService = lib.mkEnableOption "use tailscale serve to proxy radarr";
  };

  config = lib.mkIf cfg.enable {
    paul.group.transmission.enable = true;

    services.radarr = {
      enable = true;
      group = "transmission";
    };

    paul.tailscale.services = lib.mkIf cfg.enableTailscaleService { radarr.port = port; };

    clan.core.state.radarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/radarr" ];
      servicesToStop = [ "radarr.service" ];
    };
  };
}

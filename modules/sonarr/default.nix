{
  config,
  lib,
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
      settings.server.bindaddress = "127.0.0.1";
    };

    paul.tailscale.services = lib.mkIf cfg.enableTailscaleService { sonarr.port = port; };

    clan.core.state.sonarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/sonarr" ];
      servicesToStop = [ "sonarr.service" ];
    };
  };
}

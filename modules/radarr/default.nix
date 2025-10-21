{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.radarr;
in
{
  options.paul.radarr = {
    enable = lib.mkEnableOption "activate radarr";
    openTailscaleFirewall = lib.mkEnableOption "allow radarr port in firewall on tailscale interface";
  };

  config = lib.mkIf cfg.enable {
    paul.group.transmission.enable = true;

    services.radarr = {
      enable = true;
      group = "transmission";
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.radarr.settings.server.port
    ];

    clan.core.state.radarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/radarr" ];
      servicesToStop = [ "radarr.service" ];
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.prowlarr;
  port = config.services.prowlarr.settings.server.port;
in
{
  options.paul.prowlarr = {
    enable = lib.mkEnableOption "activate prowlarr";
    openTailscaleFirewall = lib.mkEnableOption "allow prowlarr port in firewall on tailscale interface";
    enableTailscaleService = lib.mkEnableOption "use tailscale serve to proxy prowlarr";
  };

  config = lib.mkIf cfg.enable {
    paul.flaresolverr.enable = true;

    services.prowlarr = {
      enable = true;
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      port
    ];

    paul.tailscale.services = lib.mkIf cfg.enableTailscaleService { prowlarr.port = port; };

    clan.core.state.prowlarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/private/prowlarr" ];
      servicesToStop = [ "prowlarr.service" ];
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.prowlarr;
in
{
  options.paul.prowlarr = {
    enable = lib.mkEnableOption "activate prowlarr";
    openTailscaleFirewall = lib.mkEnableOption "allow prowlarr port in firewall on tailscale interface";
  };

  config = lib.mkIf cfg.enable {
    paul.flaresolverr.enable = true;

    services.prowlarr = {
      enable = true;
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.prowlarr.settings.server.port
    ];

    clan.core.state.prowlarr = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/private/prowlarr" ];
      servicesToStop = [ "prowlarr.service" ];
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.sonarr;
in
{
  options.paul.sonarr = {
    enable = lib.mkEnableOption "activate sonarr";
    openTailscaleFirewall = lib.mkEnableOption "allow sonarr port in firewall on tailscale interface";
  };

  config = lib.mkIf cfg.enable {
    paul.group.transmission.enable = true;

    services.sonarr = {
      enable = true;
      group = "transmission";
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.sonarr.settings.server.port
    ];
  };
}

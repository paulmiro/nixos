{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.flaresolverr;
in
{
  options.paul.flaresolverr = {
    enable = lib.mkEnableOption "activate flaresolverr";
    openTailscaleFirewall = lib.mkEnableOption "open the firewall for flaresolverr on tailscale interface";
  };

  config = lib.mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.flaresolverr.port
    ];
  };
}

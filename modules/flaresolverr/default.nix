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
    virtualisation.oci-containers.containers.flaresolverr = {
      serviceName = "flaresolverr-docker";
      autoStart = true;
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      ports = [ "8191:8191" ];
      autoRemoveOnStop = false;
      extraOptions = [ "--restart=unless-stopped" ];
      environment = {
        LOG_LEVEL = "info";
      };
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.flaresolverr.port
    ];
  };
}

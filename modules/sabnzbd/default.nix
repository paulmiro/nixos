{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.sabnzbd;
in
{
  options.paul.sabnzbd = {
    enable = lib.mkEnableOption "enable sabnzbd";
    enableTailscaleService = lib.mkEnableOption "use tailscale serve to proxy sabnzbd";
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
    };

    # TODO move (parts of?) config here once it's done
    paul.tailscale.services = lib.mkIf cfg.enableTailscaleService {
      sabnzbd.port = 19106;
    };

    clan.core.state.sabnzbd = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/sabnzbd" ];
      servicesToStop = [ "sabnzbd.service" ];
    };
  };
}

{
  config,
  lib,
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
      group = "transmission";
    };

    systemd.services.sabnzbd = {
      preStart = lib.mkForce ""; # the config merger is broken, pr: #482639
    };

    paul.group.transmission.enable = true;

    paul.tailscale.services.sab.port = lib.mkIf cfg.enableTailscaleService 19106;

    clan.core.state.sabnzbd = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/sabnzbd" ];
      servicesToStop = [ "sabnzbd.service" ];
    };
  };
}

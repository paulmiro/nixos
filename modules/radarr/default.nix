{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.radarr;
in
{

  options.paul.radarr = {
    enable = mkEnableOption "activate radarr";
    openFirewall = mkEnableOption "allow radarr port in firewall";
  };

  config = mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableArr = true;

    ids.uids.radarr = mkForce 7878;

    users.users.radarr.isSystemUser = true; # this should be set in the services.radarr module, bit it isn't

    services.radarr = {
      enable = true;
      user = "radarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

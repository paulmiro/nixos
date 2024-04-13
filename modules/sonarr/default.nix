{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.sonarr;
in
{

  options.paul.sonarr = {
    enable = mkEnableOption "activate sonarr";
    openFirewall = mkEnableOption "allow sonarr port in firewall";
  };

  config = mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableArr = true;

    ids.uids.sonarr = mkForce 8989;

    users.users.sonarr.isSystemUser = true; # this should be set in the services.sonarr module, bit it isn't

    services.sonarr = {
      enable = true;
      user = "sonarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

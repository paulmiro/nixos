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
    paul.nfs-mounts.enableData = true;

    services.sonarr = {
      enable = true;
      user = "sonarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

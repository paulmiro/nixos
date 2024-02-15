{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.readarr;
in
{

  options.paul.readarr = {
    enable = mkEnableOption "activate readarr";
    openFirewall = mkEnableOption "allow readarr port in firewall";
  };

  config = mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableData = true;

    users.users.readarr.uid = 8787;

    services.readarr = {
      enable = true;
      user = "readarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

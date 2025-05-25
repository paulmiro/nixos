{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.readarr;
in
{

  options.paul.readarr = {
    enable = lib.mkEnableOption "activate readarr";
    openFirewall = lib.mkEnableOption "allow readarr port in firewall";
  };

  config = lib.mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableArr = true;

    users.users.readarr.uid = 8787;

    services.readarr = {
      enable = true;
      user = "readarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

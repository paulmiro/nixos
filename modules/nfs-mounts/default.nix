{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nfs-mounts;
in
{

  options.paul.nfs-mounts = {
    enableData = mkEnableOption "activate TANK1/data";
    enableJellyfin = mkEnableOption "activate BLITZ1/jellyfin";
    enablePlayground = mkEnableOption "activate TANK1/playground";
  };

  config = {
    fileSystems."/mnt/nfs/data" = mkIf cfg.enableData {
      device = "turing:/mnt/TANK1/data";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/jellyfin" = mkIf cfg.enableData {
      device = "turing:/mnt/BLITZ1/jellyfin";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/playground" = mkIf cfg.enableData {
      device = "turing:/mnt/TANK1/playground";
      fsType = "nfs";
    };
  };

}

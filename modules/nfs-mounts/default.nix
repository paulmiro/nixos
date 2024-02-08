{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nfs-mounts;
in
{

  options.paul.nfs-mounts = {
    enableData = mkEnableOption "activate TANK1/data";
    enablePhotos = mkEnableOption "activate TANK1/photos";
    enableJellyfin = mkEnableOption "activate BLITZ1/jellyfin";
    enableImmich = mkEnableOption "activate BLITZ1/immich";
    enableAuthentik = mkEnableOption "activate BLITZ1/authentik";
    enablePlayground = mkEnableOption "activate TANK1/playground";
  };

  config = {
    fileSystems."/mnt/nfs/data" = mkIf cfg.enableData {
      device = "turing:/mnt/TANK1/data";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/photos" = mkIf cfg.enablePhotos {
      device = "turing:/mnt/TANK1/photos";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/jellyfin" = mkIf cfg.enableJellyfin {
      device = "turing:/mnt/BLITZ1/apps/jellyfin";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/immich" = mkIf cfg.enableImmich {
      device = "turing:/mnt/BLITZ1/apps/immich";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/authentik" = mkIf cfg.enableAuthentik {
      device = "turing:/mnt/BLITZ1/apps/authentik";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/playground" = mkIf cfg.enablePlayground {
      device = "turing:/mnt/BLITZ1/playground";
      fsType = "nfs";
    };
  };

}

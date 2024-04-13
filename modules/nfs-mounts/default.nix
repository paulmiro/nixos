{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.nfs-mounts;
in
{

  options.paul.nfs-mounts = {
    enableArr = mkEnableOption "activate TANK2/arr";
    enablePhotos = mkEnableOption "activate TANK2/photos";
    enableJellyfin = mkEnableOption "activate BLITZ1/jellyfin";
    enableImmich = mkEnableOption "activate BLITZ1/immich";
    enableAuthentik = mkEnableOption "activate BLITZ1/authentik";
    enableHoarder = mkEnableOption "activate BLITZ1/hoarder";
    enablePlayground = mkEnableOption "activate TANK1/playground";
  };

  config = {
    fileSystems."/mnt/nfs/arr" = mkIf cfg.enableArr {
      device = "turing:/mnt/TANK2/arr";
      fsType = "nfs";
    };
    fileSystems."/mnt/nfs/photos" = mkIf cfg.enablePhotos {
      device = "turing:/mnt/TANK2/photos";
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
    fileSystems."/mnt/nfs/hoarder" = mkIf cfg.enableHoarder {
      device = "turing:/mnt/BLITZ1/apps/hoarder";
      fsType = "nfs";
    };
  };

}

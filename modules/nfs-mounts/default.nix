{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.nfs-mounts;
in
{
  options.paul.nfs-mounts = {
    enableArr = lib.mkEnableOption "activate TANK2/arr";
    enablePhotos = lib.mkEnableOption "activate TANK2/photos";
    enableJellyfin = lib.mkEnableOption "activate BLITZ1/apps/jellyfin";
    enableImmich = lib.mkEnableOption "activate BLITZ1/apps/immich";
    enableAuthentik = lib.mkEnableOption "activate BLITZ1/apps/authentik";
    enablePostgresBackup = lib.mkEnableOption "activate TANK2/postgres-backup";
    enablePlayground = lib.mkEnableOption "activate BLITZ1/playground";
  };

  config = {
    fileSystems."/mnt/nfs/arr" = lib.mkIf cfg.enableArr {
      device = "turing:/mnt/TANK2/arr";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/photos" = lib.mkIf cfg.enablePhotos {
      device = "turing:/mnt/TANK2/photos";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/jellyfin" = lib.mkIf cfg.enableJellyfin {
      device = "turing:/mnt/BLITZ1/apps/jellyfin";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/immich" = lib.mkIf cfg.enableImmich {
      device = "turing:/mnt/BLITZ1/apps/immich";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/authentik" = lib.mkIf cfg.enableAuthentik {
      device = "turing:/mnt/BLITZ1/apps/authentik";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/playground" = lib.mkIf cfg.enablePlayground {
      device = "turing:/mnt/TANK2/playground";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/postgres_backup" = lib.mkIf cfg.enablePostgresBackup {
      device = "turing:/mnt/TANK2/backups/postgres";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };
}

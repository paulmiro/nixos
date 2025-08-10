{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.nfs-mounts;
in
{
  options.paul.nfs-mounts = with lib; {
    enableArr = mkEnableOption "activate tank/arr";
    enablePhotos = mkEnableOption "activate tank/photos";
    enableJellyfin = mkEnableOption "activate BLITZ1/apps/jellyfin";
    enableImmich = mkEnableOption "activate BLITZ1/apps/immich";
    enableAuthentik = mkEnableOption "activate BLITZ1/apps/authentik";
    enablePostgresBackup = mkEnableOption "activate tank/postgres-backup";
    enablePlayground = mkEnableOption "activate BLITZ1/playground";
    enableData = mkEnableOption "activate tank/data";
  };

  config = {
    fileSystems."/mnt/nfs/arr" = lib.mkIf cfg.enableArr {
      device = "not-turing:/mnt/tank/arr";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/photos" = lib.mkIf cfg.enablePhotos {
      device = "not-turing:/mnt/tank/photos";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/jellyfin" = lib.mkIf cfg.enableJellyfin {
      device = "not-turing:/mnt/BLITZ1/apps/jellyfin";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/immich" = lib.mkIf cfg.enableImmich {
      device = "not-turing:/mnt/BLITZ1/apps/immich";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/authentik" = lib.mkIf cfg.enableAuthentik {
      device = "not-turing:/mnt/BLITZ1/apps/authentik";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/playground" = lib.mkIf cfg.enablePlayground {
      device = "not-turing:/mnt/BLITZ1/playground";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/postgres_backup" = lib.mkIf cfg.enablePostgresBackup {
      device = "not-turing:/mnt/tank/backups/postgres";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    fileSystems."/mnt/nfs/data" = lib.mkIf cfg.enableData {
      device = "not-turing:/mnt/tank/data";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };
}

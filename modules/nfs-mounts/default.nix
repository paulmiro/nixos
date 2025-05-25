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
    enableArr = mkEnableOption "activate TANK2/arr";
    enablePhotos = mkEnableOption "activate TANK2/photos";
    enableJellyfin = mkEnableOption "activate BLITZ1/apps/jellyfin";
    enableImmich = mkEnableOption "activate BLITZ1/apps/immich";
    enableAuthentik = mkEnableOption "activate BLITZ1/apps/authentik";
    enablePostgresBackup = mkEnableOption "activate TANK2/postgres-backup";
    enablePlayground = mkEnableOption "activate BLITZ1/playground";
  };

  config = {
    fileSystems."/mnt/nfs/arr" = lib.mkIf cfg.enableArr {
      device = "turing:/mnt/TANK2/arr";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/photos" = lib.mkIf cfg.enablePhotos {
      device = "turing:/mnt/TANK2/photos";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/jellyfin" = lib.mkIf cfg.enableJellyfin {
      device = "turing:/mnt/BLITZ1/apps/jellyfin";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/immich" = lib.mkIf cfg.enableImmich {
      device = "turing:/mnt/BLITZ1/apps/immich";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/authentik" = lib.mkIf cfg.enableAuthentik {
      device = "turing:/mnt/BLITZ1/apps/authentik";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/playground" = lib.mkIf cfg.enablePlayground {
      device = "turing:/mnt/BLITZ1/playground";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
    fileSystems."/mnt/nfs/postgres_backup" = lib.mkIf cfg.enablePostgresBackup {
      device = "turing:/mnt/TANK2/backups/postgres";
      fsType = "nfs";
      options = [ "x-systemd.requires=tailscaled.service" ];
    };
  };
}

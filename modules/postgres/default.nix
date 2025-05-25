{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.postgres;
in
{

  options.paul.postgres = {
    enable = lib.mkEnableOption "activate postgres";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
    };

    services.postgresqlBackup = {
      enable = true;
      backupAll = true;
      location = "/mnt/nfs/postgres_backup";
    };

    paul.nfs-mounts.enablePostgresBackup = true;
  };
}

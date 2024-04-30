{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.postgres;
in
{

  options.paul.postgres = {
    enable = mkEnableOption "activate postgres";
  };


  config = mkIf cfg.enable
    {
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

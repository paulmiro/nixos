{
  config,
  lib,
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
    };

    clan.core.state.postgres = {
      useZfsSnapshots = config.paul.zfs.enable;
      folders = [ "/var/backup/postgres" ];
      servicesToStop = lib.mkIf config.paul.zfs.enable [ "postgresqlBackup.service" ];
    };
  };
}

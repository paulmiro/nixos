{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.meilisearch;
in
{
  options.paul.meilisearch = {
    enable = lib.mkEnableOption "activate meilisearch";
  };

  config = lib.mkIf cfg.enable {
    services.meilisearch = {
      enable = true;
    };

    clan.core.state.meilisearch = {
      useZfsSnapshots = config.paul.zfs.enable;
      useRsyncCopy = !config.paul.zfs.enable;
      folders = [ "/var/lib/private/meilisearch" ];
      servicesToStop = [ "meilisearch.service" ];
    };
  };
}

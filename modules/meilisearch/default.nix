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
      # this is required because state-version < 25.05 sets the package to 1.11
      # TODO: 25.11: remove this (assuming they actually removed meilisearch_1_11)
      # -> also check if the dumpless upgrade is made the default, and remove that too if that's the case
      package = pkgs.meilisearch;
      # this allows the database to be updated automatically without having to dump and then re-import it
      settings.experimental_dumpless_upgrade = true;
    };

    clan.core.state.meilisearch = {
      useZfsSnapshots = config.paul.zfs.enable;
      useRsyncCopy = !config.paul.zfs.enable;
      folders = [ "/var/lib/private/meilisearch" ];
      servicesToStop = [ "meilisearch.service" ];
    };
  };
}

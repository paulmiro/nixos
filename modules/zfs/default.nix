{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.zfs;
in
{
  options.paul.zfs = {
    enable = lib.mkEnableOption "enable common zfs options";
  };

  config = lib.mkIf cfg.enable {
    services.zfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
        # pools not set => will scrub all pools
      };
      autoSnapshot = {
        enable = true;
        flags = "--keep-zero-sized-snapshots --parallel-snapshots --utc";
        frequent = 4;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
      trim = {
        enable = true;
      };
      zed = { }; # TODO
    };
  };
}

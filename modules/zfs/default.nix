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
    maxArcGB = lib.mkOption {
      description = "limit the amount of memory the zfs ARC can use";
      type = lib.types.nullOr lib.types.int;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = lib.mkIf (cfg.maxArcGB != null) [
      "zfs.zfs_arc_max=${toString (cfg.maxArcGB * 1024 * 1024 * 1024)}"
    ];

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

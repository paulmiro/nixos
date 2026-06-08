{ inputs, ... }:
{
  flake.nixosModules.zfs =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.paul.zfs;
    in
    {
      imports = [
        inputs.disko-zfs.nixosModules.default
      ];

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

        boot.zfs.forceImportRoot = false;

        # activate numtide/disko-zfs
        disko.zfs.enable = true;

        services.zfs = {
          autoScrub = {
            enable = true;
            interval = "monthly";
            # pools not set => will scrub all pools
          };
          autoSnapshot = {
            enable = true;
            flags = "--keep-zero-sized-snapshots --parallel-snapshots --utc";
            frequent = 0;
            hourly = 0;
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
    };
}

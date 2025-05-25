{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.grub;
in
{
  options.paul.grub = {
    enable = mkEnableOption "activate grub";
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = true;
          useOSProber = true;
          configurationLimit = 100;
        };
        grub2-theme = {
          enable = true;
          theme = "sicher";
        };
      };
      tmp.cleanOnBoot = true;
    };
  };
}

{
  config,
  grub2-themes,
  lib,
  ...
}:
let
  cfg = config.paul.grub;
in
{
  imports = [
    grub2-themes.nixosModules.default
  ];

  options.paul.grub = {
    enable = lib.mkEnableOption "activate grub";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      grub = {
        enable = true;
        device = lib.mkDefault "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        useOSProber = true;
        configurationLimit = lib.mkDefault 100;

        memtest86 = {
          enable = true;
          params = [ "onepass" ];
        };
      };
      grub2-theme = {
        enable = true;
        theme = "sicher";
      };
    };
  };
}

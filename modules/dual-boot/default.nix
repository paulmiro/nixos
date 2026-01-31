{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.dual-boot;
in
{
  options.paul.dual-boot = {
    enable = lib.mkEnableOption "enable settings for dual boot machines";
  };

  config = lib.mkIf cfg.enable {
    time.hardwareClockInLocalTime = true;
    boot.supportedFilesystems = [ "ntfs" ];
  };
}

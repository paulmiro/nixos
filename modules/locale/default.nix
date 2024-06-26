{ config, pkgs, lib, ... }:
with lib;
let cfg = config.paul.locale;
in
{

  options.paul.locale = {
    enable = mkEnableOption "activate locale";
    hardwareClockInLocalTime = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {

    # Set your time zone.
    time = {
      timeZone = "Europe/Berlin";
      hardwareClockInLocalTime = cfg.hardwareClockInLocalTime;
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

  };

}

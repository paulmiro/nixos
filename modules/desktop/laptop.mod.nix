{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.laptop;
in
{
  options.paul.laptop = {
    enable = lib.mkEnableOption "laptop-specific configuration";
  };

  config = lib.mkIf cfg.enable {

    powerManagement.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";

      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
    };

    systemd.sleep.settings.Sleep = {
      HibernateDelaySec = "30m";
    };

  };
}

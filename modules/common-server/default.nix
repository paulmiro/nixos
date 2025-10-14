{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.common-server;
in
{
  options.paul.common-server = {
    enable = lib.mkEnableOption "contains configuration that is common to all server machines";
  };

  config = lib.mkIf cfg.enable {
    paul = {
      common.enable = true;
      home-manager.profile = "server";
    };

    boot.tmp.cleanOnBoot = true;

    fonts.fontconfig.enable = lib.mkDefault false;

    environment.variables.BROWSER = "echo";

    security.sudo.wheelNeedsPassword = false;

    systemd = {
      enableEmergencyMode = false;

      # TODO: disabled for now because turing is weird
      # watchdog = {
      #   # systemd will send a signal to the hardware watchdog at half
      #   # the interval defined here, so every 10s.
      #   # If the hardware watchdog does not get a signal for 20s,
      #   # it will forcefully reboot the system.
      #   runtimeTime = "20s";
      #   # Forcefully reboot if the final stage of the reboot
      #   # hangs without progress for more than 30s.
      #   # For more info, see:
      #   #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      #   rebootTime = "30s";
      # };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}

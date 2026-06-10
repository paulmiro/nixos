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
      home-manager.profile = lib.mkDefault "server";
    };

    boot.tmp.cleanOnBoot = true;

    fonts.fontconfig.enable = lib.mkDefault false;

    environment.variables.BROWSER = "echo";

    security.sudo.wheelNeedsPassword = false;

    systemd = {
      enableEmergencyMode = false;

      sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
      };
    };

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}

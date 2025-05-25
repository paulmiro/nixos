{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.adb;
in
{
  options.paul.adb = {
    enable = lib.mkEnableOption "Enable Android development tools";
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.paulmiro.extraGroups = [ "adbusers" ];
    networking.firewall.allowedTCPPorts = [ 8081 ];
    networking.firewall.allowedUDPPorts = [ 8081 ];
  };
}

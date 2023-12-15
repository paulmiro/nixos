{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.sonarr;
in
{

  options.paul.sonarr = {
    enable = mkEnableOption "activate sonarr";
    openFirewall = mkEnableOption "allow sonarr port in firewall";
  };

  config = mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;

    services.sonarr = {
      enable = true;
      user = "sonarr";
      group = "arr";
      dataDir = "/var/lib/sonarr/.config/NzbDrone";
      openFirewall = cfg.openFirewall;
    };
  };
}

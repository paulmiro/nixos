{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.radarr;
in
{

  options.paul.radarr = {
    enable = mkEnableOption "activate radarr";
    openFirewall = mkEnableOption "allow radarr port in firewall";
  };

  config = mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;

    services.radarr = {
      enable = true;
      user = "radarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

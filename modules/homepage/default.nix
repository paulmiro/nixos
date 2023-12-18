{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.homepage;
in
{

  options.paul.homepage = {
    enable = mkEnableOption "activate homepage";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow homepage port in firewall";
    };
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };
  };
}

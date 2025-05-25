{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.prowlarr;
in
{

  options.paul.prowlarr = {
    enable = mkEnableOption "activate prowlarr";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow prowlarr port in firewall";
    };
  };

  config = mkIf cfg.enable {
    paul.flaresolverr.enable = true;

    services.prowlarr = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.prowlarr;
in
{
  options.paul.prowlarr = with lib; {
    enable = mkEnableOption "activate prowlarr";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow prowlarr port in firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    paul.flaresolverr.enable = true;
    services.prowlarr = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };
  };
}

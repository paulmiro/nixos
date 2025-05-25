{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.flaresolverr;
in
{

  options.paul.flaresolverr = {
    enable = mkEnableOption "activate flaresolverr";
    openFirewall = mkEnableOption "open the firewall for flaresolverr";

    port = mkOption {
      type = types.port;
      default = 8191;
      description = "port to listen on";
    };
  };

  config = mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      openFirewall = cfg.openFirewall;
      port = cfg.port;
    };
  };
}

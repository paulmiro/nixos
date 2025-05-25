{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.flaresolverr;
in
{

  options.paul.flaresolverr = with lib; {
    enable = mkEnableOption "activate flaresolverr";
    openFirewall = mkEnableOption "open the firewall for flaresolverr";

    port = mkOption {
      type = types.port;
      default = 8191;
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      openFirewall = cfg.openFirewall;
      port = cfg.port;
    };
  };
}

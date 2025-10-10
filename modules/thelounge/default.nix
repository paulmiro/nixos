{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.thelounge;
in
{
  options.paul.thelounge = {
    enable = lib.mkEnableOption "activate thelounge";
    openFirewall = lib.mkEnableOption "allow thelounge port in firewall";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9337;
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.thelounge = {
      enable = true;
      port = cfg.port;
      plugins = [ pkgs.theLoungePlugins.themes.flat-dark ];
      extraConfig = {
        theme = "thelounge-theme-flat-dark";

      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}

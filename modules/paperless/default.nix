{ lib, config, ... }:
with lib;
let
  cfg = config.paul.paperless;
in
{

  options.paul.paperless = {
    enable = mkEnableOption "activate paperless";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow paperless port in firewall";
    };
    port = mkOption {
      type = types.port;
      default = 28981;
      description = "port to run paperless on";
    };
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      port = cfg.port;
      address = "hawking";
    };
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}

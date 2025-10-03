{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.paperless;
in
{
  options.paul.paperless = with lib; {
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

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      port = cfg.port;
      address = "turing";
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}

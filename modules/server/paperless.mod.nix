{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.paperless;
in
{
  options.paul.paperless = {
    enable = lib.mkEnableOption "activate paperless";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "allow paperless port in firewall";
    };
    port = lib.mkOption {
      type = lib.types.port;
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

    clan.core.state.paperless = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/paperless" ];
      servicesToStop = [ "paperless.service" ];
    };
  };
}

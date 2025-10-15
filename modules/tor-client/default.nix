{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.tor-client;
in
{
  options.paul.tor-client = {
    enable = lib.mkEnableOption "enable tor client options";
  };

  config = lib.mkIf cfg.enable {
    services.tor = {
      enable = true;
      torsocks.enable = true;
      client.enable = true;
      client.dns.enable = true;
    };
  };
}

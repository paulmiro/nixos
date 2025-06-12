{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.common-server;
in
{
  options.paul.common-server = {
    enable = lib.mkEnableOption "contains configuration that is common to all server machines";
  };

  config = lib.mkIf cfg.enable {
    paul = {
      common.enable = true;

      home-manager.profile = "server";
    };
  };
}

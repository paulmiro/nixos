{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.common-server;
in
{

  options.paul.common-server = {
    enable = mkEnableOption "contains configuration that is common to all server machines";
  };

  config = mkIf cfg.enable {

    paul.common.enable = true;

  };

}

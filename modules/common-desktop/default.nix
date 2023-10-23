{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.common-desktop;
in
{

  options.paul.common-desktop = {
    enable = mkEnableOption "contains configuration that is common to all systems with a desktop environment";
  };

  config = mkIf cfg.enable {

    paul.common.enable = true;

  };

}

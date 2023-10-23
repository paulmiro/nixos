{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.common-system;
in
{

  options.paul.common-system = {
    enable = mkEnableOption "contains configuration that is common to all systems";
  };

  config = mkIf cfg.enable { };

}

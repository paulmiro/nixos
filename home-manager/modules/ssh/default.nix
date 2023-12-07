{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.ssh;
in
{
  options.paul.programs.ssh.enable = mkEnableOption "enable ssh";

  config = mkIf cfg.enable {

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "nas" = {
          hostname = "truenas";
          user = "admin";
        };
        "laptop" = {
          hostname = "newton";
          user = "paulmiro";
        };
        "apps" = {
          hostname = "hawking";
          user = "paulmiro";
        };
      };
    };
  };
}

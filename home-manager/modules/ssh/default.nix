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
        "turing" = {
          hostname = "turing";
          user = "admin";
        };
        "laptop" = {
          hostname = "newton";
          user = "paulmiro";
        };
        "hawking" = {
          hostname = "hawking";
          user = "paulmiro";
        };
        "morse" = {
          hostname = "morse-ssh.duckdns.org";
          user = "root";
        };
      };
    };
  };
}

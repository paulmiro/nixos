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
          hostname = "192.168.178.222";
          user = "admin";
        };
      };
    };
  };
}

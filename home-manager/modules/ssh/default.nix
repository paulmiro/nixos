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
        "uni" = {
          hostname = "login-stud.informatik.uni-bonn.de";
          user = "rohdep0";
        };
        "vci1" = {
          hostname = "vci-gpu1.cs.uni-bonn.de";
          user = "student_rohde";
        };
        "vci1-remote" = {
          hostname = "vci-gpu1.cs.uni-bonn.de";
          user = "student_rohde";
          proxyJump = "uni";
        };
      };
    };
  };
}

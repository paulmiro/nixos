{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.programs.ssh;
in
{
  options.paul.programs.ssh = {
    enable = lib.mkEnableOption "enable ssh";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; # the "*" match block currently contains these default values
      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
        "turing" = {
          hostname = "turing";
          user = "admin";
        };
        "newton" = {
          hostname = "newton";
          user = "paulmiro";
        };
        "hawking" = {
          hostname = "hawking";
          user = "paulmiro";
        };
        "morse" = {
          hostname = "morse";
          user = "paulmiro";
        };
        "uni" = {
          hostname = "login-stud.informatik.uni-bonn.de";
          user = "rohdep0";
        };
        "vci1" = {
          hostname = "vci-gpu1.cs.uni-bonn.de";
          user = "student_rohde";
        };
      };
    };
  };
}

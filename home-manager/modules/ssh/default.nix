{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.ssh;
in
{
  options.paul.ssh = {
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
          user = "paulmiro";
        };
        "newton" = {
          hostname = "newton";
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
      };
    };
  };
}

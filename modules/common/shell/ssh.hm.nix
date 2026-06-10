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
      settings = {
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

    home.activation = {
      # nix-community/home-manager#322
      # ssh has a check to enforce proper permissions of the ~/.ssh/config file
      # fhs environments break this, so we copy the file instead of symlinking it
      # original snippet uses 0600, but i don't want the file to be editable
      fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run install -d -m 0700 "$HOME/.ssh"
        if [ -L "$HOME/.ssh/config" ]; then
          src="$(readlink -f "$HOME/.ssh/config")"
          run rm -f "$HOME/.ssh/config"
          run install -m 0400 "$src" "$HOME/.ssh/config"
        fi
      '';
    };
    home.file = {
      # home-manager wrongly thinks it doesn't manage (and thus shouldn't clobber) this file due to the activation script
      ".ssh/config".force = true;
    };
  };
}

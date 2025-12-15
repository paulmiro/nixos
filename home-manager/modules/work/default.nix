{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.work;
in
{
  options.paul.work = {
    enable = lib.mkEnableOption "enable work stuff";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.matchBlocks = {
      "build-nixos" = {
        hostname = "build-nixos";
        user = "bettertec";
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
      "betterbuild" = {
        hostname = "betterbuild";
        user = "bettertec";
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
      "git.bettertec.internal" = {
        hostname = "git.bettertec.internal";
        user = "forgejo";
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
    };
  };
}

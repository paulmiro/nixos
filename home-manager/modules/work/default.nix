{
  betternix,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.work;
in
{
  imports = [
    betternix.homeModules.default
  ];

  options.paul.work = {
    enable = lib.mkEnableOption "enable work stuff";
  };

  config = lib.mkIf cfg.enable {
    betternix.ssh.enable = true;

    programs.ssh.matchBlocks = {
      "betterbuild" = {
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
      "git.bettertec.internal" = {
        extraOptions = {
          IdentityFile = "~/.ssh/id_ed25519_pr";
        };
      };
    };
  };
}

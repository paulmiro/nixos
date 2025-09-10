{
  ...
}:
{
  config = {
    programs.ssh.matchBlocks = {
      "build-nixos" = {
        hostname = "build-nixos";
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

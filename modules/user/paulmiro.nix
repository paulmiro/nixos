{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.user.paulmiro;
in
{
  options.paul.user.paulmiro = {
    enable = lib.mkEnableOption "activate user paulmiro";
  };

  config = lib.mkIf cfg.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.paulmiro = {
      isNormalUser = true;
      description = "Paul";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = lib.mkIf config.programs.zsh.enable pkgs.zsh;
      hashedPasswordFile =
        config.clan.core.vars.generators.user-password-paulmiro.files.hashed-password.path;
      openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys; # looks stupid but does the job
    };

    clan.core.vars.generators.user-password-paulmiro = {
      prompts.password.description = "Password for unix user paulmiro (see bw)";
      prompts.password.type = "hidden";
      prompts.password.persist = false;

      files.hashed-password.secret = false;

      runtimeInputs = [ pkgs.mkpasswd ];
      script = "cat $prompts/password | mkpasswd -m sha-512 > $out/hashed-password";
    };

    nix.settings = {
      allowed-users = [ "paulmiro" ];
    };
  };
}

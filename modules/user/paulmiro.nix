{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.user.paulmiro;
in
{

  options.paul.user.paulmiro = { enable = mkEnableOption "activate user paulmiro"; };

  config = mkIf cfg.enable {

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.paulmiro = {
      isNormalUser = true;
      description = "Paul";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = mkIf config.programs.zsh.enable pkgs.zsh;
      initialHashedPassword = config.paul.private.hashed-password-paulmiro;
      openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys; # looks stupid but does the job
    };

    nix.settings = {
      allowed-users = [ "paulmiro" ];
    };

  };
}

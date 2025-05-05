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
      openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/paulmiro.keys";
          hash = "sha256-v+pYtIUN/hXvkWD+eEW1g8iL9DelIQXnDmmCZnvK15g=";
        })
      ];
    };

    nix.settings = {
      allowed-users = [ "paulmiro" ];
    };

  };
}

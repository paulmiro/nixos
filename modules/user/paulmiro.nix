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
      openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/paulmiro.keys";
          hash = "sha256-c5emlywLPQqDckO7SuA8yMLgDLTocL4RDN5g54i02bE=";
        })
      ];
    };

    nix.settings = {
      allowed-users = [ "paulmiro" ];
    };

  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.user.root;
in
{

  options.paul.user.root = {
    enable = mkEnableOption "activate user root";
  };

  config = mkIf cfg.enable {

    users.users.root = {
      openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/paulmiro.keys";
          hash = "sha256-eoXjsJ0y9a5TcjpKnN4wPLNf/iOtG1TqzcOq+dqRT/c=";
        })
      ];
    };

  };
}

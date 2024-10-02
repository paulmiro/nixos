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
          hash = "sha256-HdSekdjOMl3Fqp8jMT0JOZvp/V8mS8r59bk2MOSJxE0=";
        })
      ];
    };

  };
}

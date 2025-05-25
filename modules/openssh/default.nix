{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.openssh;
in
{

  options.paul.openssh = {
    enable = lib.mkEnableOption "activate openssh";
  };

  config = lib.mkIf cfg.enable {

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

  };
}

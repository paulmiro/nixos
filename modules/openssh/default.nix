{
  config,
  lib,
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
    services.openssh = {
      enable = true;
      # startWhenNeeded = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}

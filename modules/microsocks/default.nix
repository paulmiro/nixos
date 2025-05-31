{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.microsocks;
  authPasswordFile = "/run/keys/microsocks-auth-password";
in
{
  options.paul.microsocks = with lib; {
    enable = mkEnableOption "activate microsocks";
    openFirewall = mkEnableOption "open the firewall for microsocks";

    port = mkOption {
      type = types.port;
      default = 1080;
      description = "port to listen on";
    };

    authPasswordFile = mkOption {
      type = types.str;
      default = "/run/keys/microsocks-auth-password";
      description = "path to put the auth password file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.microsocks = {
      enable = true;
      ip = "0.0.0.0";
      authUsername = "socks";
      authPasswordFile = authPasswordFile;
    };

    users.users.microsocks.extraGroups = [ "keys" ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # this breaks on first deploy, because the user does not exist yet
    # to fix this, three steps are needed:
    # 1. comment out this secrets block and deploy
    # 2. uncomment and deploy again
    # 3. (if needed) sudo systemctl restart microsocs.service

    # TODO: replace with clan secrets
    # lollypops.secrets.files."microsocks-auth-password" = {
    #   cmd = "rbw get microsocks-auth-password";
    #   path = cfg.authPasswordFile;
    #   owner = "microsocks";
    # };
  };
}

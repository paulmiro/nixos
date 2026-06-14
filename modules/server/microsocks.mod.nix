{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.microsocks;
in
{
  options.paul.microsocks = {
    enable = lib.mkEnableOption "activate microsocks";
    openFirewall = lib.mkEnableOption "open the firewall for microsocks";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1080;
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.microsocks = {
      enable = true;
      ip = "0.0.0.0";
      authUsername = "socks";
      authPasswordFile = config.clan.core.vars.generators.microsocks.files.auth-password.path;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    clan.core.vars.generators.microsocks = {
      prompts.auth-password.description = "MicroSocks Auth Password (see bw)";
      prompts.auth-password.type = "hidden";
      prompts.auth-password.persist = false;

      files.auth-password.secret = true;
      files.auth-password.owner = "microsocks";

      script = "cp $prompts/auth-password $out/auth-password";
    };
  };
}

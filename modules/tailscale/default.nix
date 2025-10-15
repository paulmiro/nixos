{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.tailscale;
in
{
  options.paul.tailscale = {
    enable = lib.mkEnableOption "enable tailscale";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      authKeyFile = config.clan.core.vars.generators.tailscale.files.auth-key.path;
      extraUpFlags = [
        "--operator=paulmiro"
      ];
    };

    clan.core.vars.generators.tailscale = {
      prompts.auth-key.description = "Tailscale Auth Key";
      prompts.auth-key.type = "hidden";
      prompts.auth-key.persist = false;

      files.auth-key.secret = true;

      script = ''
        cat $prompts/auth-key > $out/auth-key
      '';
    };
  };
}

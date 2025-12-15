{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.tailscale;
in
{
  imports = [
    ./services.nix
  ];

  options.paul.tailscale = {
    enable = lib.mkEnableOption "enable tailscale";
    exitNode = lib.mkEnableOption "enable exit node";
    routingFeatures = lib.mkOption {
      type = lib.types.enum [ "server" "client" "both" ];
      default = "server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = cfg.routingFeatures;
      authKeyFile = config.clan.core.vars.generators.tailscale.files.auth-key.path;
      extraUpFlags = [
        "--operator=paulmiro"
        "--accept-routes"
      ]
      ++ (lib.optional cfg.exitNode "--advertise-exit-node");
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

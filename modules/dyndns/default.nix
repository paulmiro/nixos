{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.dyndns;
  domains =
    (map (vhost: (if vhost.value.serverName != null then vhost.value.serverName else vhost.name)) (
      builtins.filter (vhost: vhost.value.enableDyndns) (
        lib.attrsToList config.services.nginx.virtualHosts
      )
    ))
    ++ cfg.extraDomains;
  enable = (!cfg.forceDisable) && ((builtins.length domains) != 0);
in
{
  options.paul.dyndns = {
    forceDisable = lib.mkEnableOption "force disable dyndns";

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "extra domains to update";
    };

    _enable = lib.mkEnableOption "enable dyndns"; # readonly for other services
  };

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options = {
            enableDyndns = lib.mkEnableOption "enable dyndns";
          };
        }
      )
    );
  };

  config = lib.mkIf enable {
    paul.dyndns._enable = lib.mkForce true;

    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = config.clan.core.vars.generators.cloudflare-dyndns.files.api-token.path;
      ipv4 = true;
      ipv6 = false;
      domains = domains;
    };

    clan.core.vars.generators.cloudflare-dyndns = {
      prompts.api-token.description = "Cloudflare API Token with permissions to edit DNS (see bw)";
      prompts.api-token.type = "hidden";
      prompts.api-token.persist = false;

      files.api-token.secret = true;

      share = true;

      script = "cp $prompts/api-token $out/api-token";
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.dyndns;
in
{
  options.paul.dyndns = with lib; {
    enable = mkEnableOption "activate dyndns";

    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "domains to update";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = config.clan.core.vars.generators.cloudflare-dyndns.files.api-token.path;
      ipv4 = true;
      ipv6 = false;
      domains = cfg.domains;
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

{
  config,
  lib,
  pkgs,
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
    forceDisable = lib.mkEnableOption "force disable dyndns systemwide";

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "extra domains to update";
    };
  };

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { ... }:
        {
          options = {
            enableDyndns = lib.mkEnableOption "enable dyndns";
          };
        }
      )
    );
  };

  config = lib.mkIf enable {
    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = config.clan.core.vars.generators.cloudflare-dyndns.files.api-token.path;
      ipv4 = true;
      ipv6 = false;
      domains = domains;
    };

    systemd.services = lib.mkMerge (
      map (domain: {
        "acme-${domain}" = {
          after = [ "cloudflare-dyndns.service" ];
          serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
        };
      }) (builtins.filter (domain: !(lib.strings.hasInfix "*" domain)) domains)
    );

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

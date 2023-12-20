{ lib, pkgs, config, self, ... }:
with lib;
let cfg = config.paul.dyndns;
in
{

  options.paul.dyndns = {
    enable = mkEnableOption "activate dyndns";
    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "domains to update";
    };
  };

  config = mkIf cfg.enable {
    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = "${"${self}/secrets/cloudflare-token"}";
      ipv4 = true;
      ipv6 = true;
      domains = cfg.domains;
    };
  };
}

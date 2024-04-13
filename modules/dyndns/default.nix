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

    apiTokenFile = mkOption {
      type = types.str;
      default = "/run/keys/cloudflare-api-token";
      description = "path to the file containing the cloudflare api token";
    };
  };

  config = mkIf cfg.enable {
    services.cloudflare-dyndns = {
      enable = true;
      apiTokenFile = cfg.apiTokenFile;
      ipv4 = true;
      ipv6 = false;
      domains = cfg.domains;
    };

    lollypops.secrets.files."cloudflare-api-token" = {
      cmd = "echo \"CLOUDFLARE_API_TOKEN=$(bw get item cloudflare | jq -r '.fields[] | select(.name == \"api-token-edit-dns-all\") | .value')\"";
      path = cfg.apiTokenFile;
      mode = "0444";
    };
  };
}

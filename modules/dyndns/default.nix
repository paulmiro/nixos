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
      # TODO remove this when kissgyorgy/cloudflare-dyndns/pull/41 is merged
      package = (pkgs.cloudflare-dyndns.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "paulmiro";
          repo = "cloudflare-dyndns";
          rev = "df8240502db79c54564e01a25e468189a2494d06";
          sha256 = "sha256-jLmGPwCcIJLNw+XgjYfkFhHfzIRtLArjt8WiHKqYR2s=";
        };
      }));
    };

    lollypops.secrets.files."cloudflare-api-token" = {
      cmd = "rbw get cloudflare-api-token-edit-dns-all";
      path = cfg.apiTokenFile;
    };
  };
}

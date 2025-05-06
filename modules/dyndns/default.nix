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
      # TODO remove this when a new release (>5.3) is released on nixpkgs-unstable
      package = (pkgs.cloudflare-dyndns.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "kissgyorgy";
          repo = "cloudflare-dyndns";
          rev = "ad970df12e235c7fd473a922f663d912ba7107fc";
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

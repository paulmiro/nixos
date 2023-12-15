{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.flaresolverr;
in
{

  options.paul.flaresolverr = {
    enable = mkEnableOption "activate flaresolverr";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Documentation placeholder
      '';
    };

    port = mkOption {
      type = types.str;
      default = "8191";
      description = ''
        Documentation placeholder
      '';
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers.flaresolverr = {
      autoStart = true;
      image = "flaresolverr/flaresolverr";
      ports = [ "8191:${cfg.port}/tcp" ];
    };

  };
}

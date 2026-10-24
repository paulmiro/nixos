{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.flaresolverr;
in
{
  options.paul.flaresolverr = {
    enable = lib.mkEnableOption "activate flaresolverr";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.flaresolverr = {
      serviceName = "flaresolverr";
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoUpdate = "daily";
      ports = [ "8191:8191" ];
      autoRemoveOnStop = false;
      extraOptions = [ "--restart=unless-stopped" ];
      environment = {
        LOG_LEVEL = "info";
      };
    };
  };
}

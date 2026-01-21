{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.hypermind;
  port = 19108;
in
{
  options.paul.hypermind = {
    enable = lib.mkEnableOption "enable hypermind";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    virtualisation.oci-containers.containers.hypermind = {
      serviceName = "hypermind-docker";
      autoStart = true;
      image = "ghcr.io/lklynet/hypermind";
      environment = {
        PORT = toString port;
        ENABLE_CHAT = "true";
        ENABLE_MAP = "true";
        ENABLE_THEMES = "true";
      };
      extraOptions = [
        "--network=host"
      ];
    };

  };
}

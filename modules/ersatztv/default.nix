{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.ersatztv;
  hardwareVersion =
    if cfg.hardwareTranscoding == "vaapi" || cfg.hardwareTranscoding == "qsv" then
      "-vaapi"
    else if cfg.hardwareTranscoding == "nvenc" then
      "-nvidia"
    else
      "";
  serviceName = "ersatztv-docker";
in
{
  options.paul.ersatztv = {
    enable = lib.mkEnableOption "activate ersatztv";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "open the firewall for ersatztv";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8409;
      description = "port to listen on";
    };

    configDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/ersatztv";
      description = "directory where ersatztv stores its config";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "ersatztv version to use";
    };

    hardwareTranscoding = lib.mkOption {
      type = lib.types.enum [
        "off"
        "nvenc"
        "vaapi"
        "qsv"
      ];
      default = "off";
      description = "enable hardware transcoding";
    };
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    virtualisation.oci-containers.containers.ersatztv = {
      inherit serviceName;
      autoStart = true;
      image = "jasongdove/ersatztv:${cfg.version}${hardwareVersion}";
      ports = [ "8409:${toString cfg.port}/tcp" ];
      volumes = [
        "${cfg.configDirectory}:/root/.local/share/ersatztv"
        "/mnt/nfs/arr/media:/media:ro"
      ];
      extraOptions = [
        "-e TZ=America/Chicago"
      ]
      ++ lib.optionals (cfg.hardwareTranscoding == "qsv") [
        # get group ID with: `getent group render | cut -d: -f3`
        "--group-add=303"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
      ]
      ++ lib.optionals (cfg.hardwareTranscoding == "nvenc") [
        "--gpus"
        "all"
      ];
    };

    clan.core.state.ersatztv = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/ersatztv" ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}

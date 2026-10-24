{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    mapAttrs'
    nameValuePair
    filterAttrs
    escapeShellArg
    ;

  docker = "${config.virtualisation.docker.package}/bin/docker";

  autoUpdatingContainers = filterAttrs (
    _name: containerConfig: containerConfig.autoUpdate != null
  ) config.virtualisation.oci-containers.containers;

  unitName = name: "docker-${name}-autoupdate";
in
{
  options.virtualisation.oci-containers.containers = mkOption {
    type = types.attrsOf (
      types.submodule {
        options.autoUpdate = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "weekly";
          description = "set to a systemd calendar expression to update the container automatically";
        };
      }
    );
  };

  config = {
    systemd.timers = mapAttrs' (
      name: c:
      nameValuePair (unitName name) {
        description = "timer for container update ${name}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = c.autoUpdate;
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      }
    ) autoUpdatingContainers;

    systemd.services = mapAttrs' (
      name: containerConfig:
      nameValuePair (unitName name) {
        description = "update container ${name}";
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "docker.service"
        ];
        requires = [ "docker.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${docker} pull ${escapeShellArg containerConfig.image}

          latest=$(${docker} image inspect --format '{{.Id}}' ${escapeShellArg containerConfig.image})
          running=$(${docker} inspect --format '{{.Image}}' ${escapeShellArg name} 2>/dev/null || true)

          if [ "$latest" != "$running" ]; then
            echo "Update found for ${name} ($running -> $latest). restarting..."
            systemctl try-restart ${containerConfig.serviceName}.service
          else
            echo "${name} is already up to date"
          fi
        '';
      }
    ) autoUpdatingContainers;
  };
}

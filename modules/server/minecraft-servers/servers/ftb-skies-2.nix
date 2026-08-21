{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "ftb-skies-2"; # do not change!
  packId = "129";
  packVersion = "100441";

  dataDir = "${config.services.minecraft-servers.dataDir}/${name}";
  serviceName = "minecraft-server-${name}";

  cfg = config.paul.minecraft-servers.${name};
in
{
  options.paul.minecraft-servers.${name} = {
    enable = lib.mkEnableOption "activate Ftb Skies 2 Minecraft Server";
  };

  config = lib.mkIf cfg.enable {

    services.minecraft-servers = {
      enable = true;

      servers = {
        ${name} = {
          enable = true;
          package = pkgs.neoforgeServers.neoforge-1_21_1;
          openFirewall = true;
          autoStart = true;
          jvmOpts = "-Xms512M -Xmx8192M";

          extraStartPre = ''
            if [ ! -f ${dataDir}/INSTALLER_DONE ] && [ ! -f ${dataDir}/INSTALLER_STARTED ]; then
              echo "Running Installer..."
              echo 1 > ${dataDir}/INSTALLER_STARTED
              ${lib.getExe pkgs.paulmiro.ftb-server-installer} -pack ${packId} -version ${packVersion} -dir ${dataDir} -auto -force -just-files -no-java -skip-modloader
              rm -f ${dataDir}/INSTALLER_STARTED
              echo 1 > ${dataDir}/INSTALLER_DONE
              echo "Installer done."
            elif [ -f ${dataDir}/INSTALLER_STARTED ]; then
              echo "Installer failed to finish last time. Aborting."
              exit 1
            else
              echo "Installer already done."
            fi
          '';

          whitelist = {
            "Powlcopter" = "67fe19ee-2203-4c5d-8f5e-94c43583afa6";
          };
          operators = {
            "Powlcopter" = {
              uuid = "67fe19ee-2203-4c5d-8f5e-94c43583afa6";
              level = 3;
              bypassesPlayerLimit = true;
            };
          };
        };
      };
    };

    # allow modpack download to take up to 15 minutes
    systemd.services.${serviceName}.serviceConfig.TimeoutStartSec = "15min";

    clan.core.state.minecraft-ftb-skies-2 = {
      useZfsSnapshots = true;
      folders = [ dataDir ];
      servicesToStop = [ "${serviceName}.service" ];
    };

  };
}

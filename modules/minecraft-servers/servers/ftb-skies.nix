{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.paul.minecraft-servers.ftb-skies;
in
{
  # This Modpack uses a lot of stateful stuff, so i chose to just write my own systemd-service
  # instead of hacking around one of the many ways to do it the nix way

  options.paul.minecraft-servers.ftb-skies = {
    enable = mkEnableOption "activate FTB Skies Minecraft Server";
  };

  config = mkIf cfg.enable {
    systemd.services.mc-ftb-skies = {
      description = "Minecraft Server FTB Skies";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [ temurin-bin-17 bash ];

      environment = {
        JVMOPTS = "-Xms2G -Xmx8G"; # use min 2GB and max 8GB of memory
      };

      serviceConfig =
        {
          Restart = "always";
          ExecStart = "/var/lib/mc-ftb-skies/start.sh";
          ExecStop = ''
            ${pkgs.mcrcon}/bin/mcrcon stop
          '';
          TimeoutStopSec = "20";
          User = "mc-ftb-skies";
          StateDirectory = "mc-ftb-skies";
          WorkingDirectory = "/var/lib/mc-ftb-skies";
        };

      preStart = ''
        # Ensure EULA is accepted
        echo "eula=true" > eula.txt
      '';
    };

    users.users.mc-ftb-skies = {
      description = "Minecraft server service user for instance mc-ftb-skies";
      isSystemUser = true;
      useDefaultShell = true;
      createHome = true;
      group = "mc-ftb-skies";
      home = "/var/lib/mc-ftb-skies";
    };

    users.groups.mc-ftb-skies = { };

    networking.firewall = {
      allowedUDPPorts = [ 25565 ];
      allowedTCPPorts = [ 25565 ];
    };
  };
}

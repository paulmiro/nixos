{ pkgs, lib, config, ... }:
with lib;
let cfg = config.paul.hoarder;
in
{

  options.paul.hoarder = {
    enable = mkEnableOption "activate hoarder";
    openFirewall = mkEnableOption "open firewall for hoarder";
    enableNginx = mkEnableOption "activate nginx proxy";
    enableDyndns = mkOption {
      type = types.bool;
      default = true;
      description = "enable dyndns";
    };

    port = mkOption {
      type = types.port;
      default = 2284; # THIS IS NOT A DEFAULT, IT'S JUST IMMICH+1
      description = "port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "hoarder.pamiro.net";
      description = "domain name for hoarder";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      paul.nfs-mounts = {
        enableHoarder = true;
      };

      
      systemd.services.docker-hoarder = {
        description = "hoarder docker-compose service";
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
          "mnt-nfs-hoarder.mount"
          "remote-fs.target"
        ];
        serviceConfig = {
          WorkingDirectory = "${./compose}";
          ExecStart = "${pkgs.docker}/bin/docker compose up --build";
          Restart = "on-failure";
        };
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    }

    (mkIf cfg.enableNginx {
      paul.nginx.enable = true;
      paul.dyndns = mkIf cfg.enableDyndns {
        enable = true;
        domains = [ cfg.domain ];
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          geo-ip = true;
        };
      };
    })

  ]);

}

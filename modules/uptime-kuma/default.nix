{ lib, pkgs, config, ... }:
let cfg = config.paul.uptime-kuma; in
{

  options.paul.uptime-kuma = with lib; {
    enable = mkEnableOption "activate uptime-kuma";

    enableNginx = mkEnableOption "activate nginx for uptime-kuma";

    openFirewall = mkEnableOption "open the firewall for uptime-kuma";

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      appriseSupport = true;
      settings = {
        PORT = toString cfg.port;
        HOST = "0.0.0.0";
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}

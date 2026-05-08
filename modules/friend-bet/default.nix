{
  config,
  friend-bet,
  lib,
  ...
}:
let
  cfg = config.paul.friend-bet;
  port = 19112;
  domain = config.paul.private.domains.friend-bet;
  name = config.paul.private.misc.friend_bet_name;
in
{
  imports = [
    friend-bet.nixosModules.friend-bet
  ];

  options.paul.friend-bet = {
    enable = lib.mkEnableOption "enable friend-bet";
    openFirewall = lib.mkEnableOption "open firewall for friend-bet";
    enableNginx = lib.mkEnableOption "activate nginx proxy";
  };

  config = lib.mkIf cfg.enable {

    services.friend-bet = {
      enable = true;
      inherit port name;
    };

    clan.core.state.friend-bet = {
      useRsyncCopy = true;
      folders = [ "/var/lib/friend-bet" ];
      servicesToStop = [ "friend-bet.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ port ];

    services.nginx.virtualHosts."${domain}" = lib.mkIf cfg.enableNginx {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        enableGeoIP = true;
        proxyWebsockets = true;
      };
    };
  };
}

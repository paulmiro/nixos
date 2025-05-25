{
  config,
  lib,
  nix-minecraft,
  pkgs,
  ...
}:
let
  cfg = config.paul.minecraft-servers.vanilla;
in
{
  options.paul.minecraft-servers.vanilla = with lib; {
    enable = mkEnableOption "activate Vanilla Minecraft Server";
    enableDyndns = mkEnableOption "enable dyndns";
    domain = mkOption {
      type = types.str;
      default = "mc.${config.paul.private.domains.base}";
      description = "domain name for Vanilla Minecraft Server";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.paulmiro.extraGroups = [ "minecraft" ];
    nixpkgs.overlays = [ nix-minecraft.overlay ];
    paul.dyndns.domains = lib.mkIf cfg.enableDyndns [ cfg.domain ];

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8100";
        geo-ip = true;
      };
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      dataDir = "/var/lib/minecraft-servers";

      servers = {
        vanilla = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_4;
          openFirewall = true;
          autoStart = true;
          jvmOpts = "-Xms4G -Xmx5G";

          symlinks = {
            "plugins/bluemap-5.5-paper.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/KDFOHrSO/bluemap-5.5-paper.jar";
              sha512 = "858805ca7187216b82817fb3e697a9d5bfb8d215f399dee653f9152bea4b6292d1d271c6287195cafa53cdec774e964e8a6d6a7ed018e397e72525d102c4dc0c";
            };
          };
        };
      };
    };

  };
}

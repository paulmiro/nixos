{ lib, pkgs, config, nix-minecraft, ... }:
with lib;
let cfg = config.paul.minecraft-servers.vanilla; in
{
  options.paul.minecraft-servers.vanilla = {
    enable = mkEnableOption "activate Vanilla Minecraft Server";
    enableDyndns = mkEnableOption "enable dyndns";
    domain = mkOption {
      type = types.str;
      default = "mc.${config.paul.private.domains.base}";
      description = "domain name for Vanilla Minecraft Server";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];
    paul.dyndns = mkIf cfg.enableDyndns {
      enable = true;
      domains = [ cfg.domain ];
    };
    services.minecraft-servers = {
      enable = true;
      eula = true;

      # package = pkgs.minecraft-server-1-12;
      dataDir = "/var/lib/minecraft-servers";

      servers = {
        vanilla = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_4;
          openFirewall = true;
          autoStart = true;

          symlinks = {
            plugins = pkgs.linkFarmFromDrvs "plugins"
              (builtins.attrValues {
                BlueMap = fetchurl {
                  url = "https://cdn.modrinth.com/data/swbUV1cr/versions/KDFOHrSO/bluemap-5.5-paper.jar";
                  sha512 = "858805ca7187216b82817fb3e697a9d5bfb8d215f399dee653f9152bea4b6292d1d271c6287195cafa53cdec774e964e8a6d6a7ed018e397e72525d102c4dc0c";
                };
              });
          };

          serverProperties = {
            enforce-secure-profile = false; # turns off message signing
            enforce-whitelist = true;
            spawn-protection = 0;
          };

          #whitelist = { /* */ };

        };



      };


    };

  };
}

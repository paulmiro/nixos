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

          #serverProperties = { /* */ };
          #whitelist = { /* */ };

        };



      };


    };

  };
}

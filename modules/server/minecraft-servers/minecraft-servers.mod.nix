{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ]
  ++ (map (x: import (./servers + "/${x}")) (builtins.attrNames (builtins.readDir ./servers)));

  config = lib.mkIf config.services.minecraft-servers.enable {
    users.users.paulmiro.extraGroups = [ "minecraft" ];

    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    services.minecraft-servers = {
      eula = true;
      dataDir = "/var/lib/minecraft-servers";
    };
  };
}

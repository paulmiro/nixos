{ inputs, ... }:
{
  flake.nixosModules.minecraft-servers =
    {
      ...
    }:
    {
      imports = [
        inputs.nix-minecraft.nixosModules.minecraft-servers
      ];
    };
}

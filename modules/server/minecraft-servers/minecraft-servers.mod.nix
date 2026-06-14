{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ]
  ++ (map (x: import (./servers + "/${x}")) (builtins.attrNames (builtins.readDir ./servers)));
}

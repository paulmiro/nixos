{ ... }:
{
  imports = (map (x: import (./servers + "/${x}")) (builtins.attrNames (builtins.readDir ./servers)));
}

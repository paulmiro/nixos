{ lib, ... }:
{
  options.paul.private = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };

  config.paul.private = lib.mkForce (builtins.fromJSON (builtins.readFile ./private.json));
}

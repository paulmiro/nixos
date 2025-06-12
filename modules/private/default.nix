{ lib, ... }:
let
  file = builtins.readFile ./private.json;
in
{
  options.paul.private = lib.mkOption {
    type = lib.types.attrs;
    default = {
      is_decrypted = "no";
    };
  };

  config.paul.private = lib.mkForce (
    assert lib.assertMsg (lib.hasPrefix "{" file) ''
      private.json has not been decrypted!
      please read modules/private/README.md for instructions
    '';
    builtins.fromJSON (file)
  );
}

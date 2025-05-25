{ lib, ... }:
let
  data = builtins.fromJSON (builtins.readFile ./private.json);
in
{
  options.paul.private = lib.mkOption {
    type = lib.types.attrs;
    default = {
      is_decrypted = "no";
    };
  };
  config.paul.private = lib.mkForce (
    assert lib.assertMsg (data.is_decrypted == "yes") ''
      private.json has not been decrypted!
      please read modules/private/README.md for instructions
    '';
    data
  );
}

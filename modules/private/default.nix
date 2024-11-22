{ lib, ... }:
with lib;
let data = builtins.fromJSON (builtins.readFile ./private.json); in
{
  options.paul.private = mkOption {
    type = types.attrs;
    default = { is_decrypted = "no"; };
  };
  config.paul.private = mkForce (
    assert assertMsg (data.is_decrypted == "yes") ''
      private.json has not been decrypted!
      please read modules/private/README.md for instructions
    '';
    data
  );
}

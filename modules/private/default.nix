{ lib, ... }:
let
  private = builtins.readFile ./private.toml;
  is_encrypted = lib.hasPrefix "-----BEGIN AGE ENCRYPTED FILE-----" private;
  allow_fake = import ./allow_fake;
  data = fromTOML (
    if is_encrypted then
      lib.throwIfNot allow_fake ''
        Private data has not been decrypted.

        If you are not paulmiro, simply switch to the "no-private-data" branch or edit the contents of ./modules/private/allow_fake to "true".

        You can refer to modules/private/README.md for more information.
      '' builtins.readFile ./fake_private.toml
    else
      private
  );
in
{
  flake.private = data;
}

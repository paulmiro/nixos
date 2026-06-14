{ lib, ... }:
let
  inherit (lib)
    hasPrefix
    readFile
    throwIfNot
    ;
  private = readFile ./private.toml;
  is_encrypted = hasPrefix "-----BEGIN AGE ENCRYPTED FILE-----" private;
  allow_fake = import ./allow_fake.nix;
  data = fromTOML (
    if is_encrypted then
      throwIfNot allow_fake ''
        Private data has not been decrypted.

        If you are not paulmiro, simply switch to the "no-private-data" branch or edit the contents of ./modules/private/allow_fake.nix to "true".

        You can refer to modules/private/README.md for more information.
      '' readFile ./fake_private.toml
    else
      private
  );
in
{
  flake.private = data;
}

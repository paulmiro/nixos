{ lib, ... }:
{
  flake.versions = lib.mapAttrs (name: value: value.version) (
    fromTOML (builtins.readFile ./versions.toml)
  );
}

{
  lib,
  ...
}:
{
  options.paul.versions = lib.mkOption {
    description = "versions for stuff that is not nix-managed, updated manually or with github actions";
    type = lib.types.attrsOf lib.types.str;
  };

  config = {
    paul.versions = lib.mapAttrs (name: value: value.version) (
      fromTOML (builtins.readFile ./versions.toml)
    );
  };
}

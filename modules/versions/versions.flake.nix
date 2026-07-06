{ lib, ... }:
{
  flake.versions = lib.mapAttrs (name: value: value.version) (
    fromTOML (builtins.readFile ./versions.toml)
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.update-versions = pkgs.writers.writePython3Bin "update-versions" {
        libraries = with pkgs.python3Packages; [
          pygithub
          semver
        ];
        flakeIgnore = [
          "E501"
        ];
      } (builtins.readFile ./update-versions.py);
    };
}

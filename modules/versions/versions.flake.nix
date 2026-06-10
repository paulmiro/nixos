{ lib, ... }:
{
  flake.versions = lib.mapAttrs (name: value: value.version) (
    fromTOML (builtins.readFile ./versions.toml)
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.update-versions = pkgs.writers.writePython3Bin "update-versions" {
        libraries = [ pkgs.python3Packages.pygithub ];
        flakeIgnore = [
          "E501"
        ];
      } (builtins.readFile ./main.py);
    };
}

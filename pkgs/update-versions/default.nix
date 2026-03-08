{
  writers,
  python3Packages,
  ...
}:

writers.writePython3Bin "update-versions" {
  libraries = [ python3Packages.pygithub ];
  flakeIgnore = [
    "E501"
  ];
} (builtins.readFile ./update-versions.py)

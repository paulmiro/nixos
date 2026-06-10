{
  self,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    attrValues
    listToAttrs
    readDir
    removeSuffix
    ;
in
{
  # TODO: import these with import-all
  flake.homeProfiles = listToAttrs (
    map (filename: {
      name = removeSuffix ".nix" filename;
      value = {
        imports = [
          ./profiles/common.nix
          (./profiles + "/${filename}")
        ]
        ++ (attrValues self.homeModules);
      };
    }) (attrNames (readDir ./profiles))
  );
}

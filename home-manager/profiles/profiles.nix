{
  lib,
  moduleLocation,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
in
{
  options = {
    flake.homeProfiles = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = mapAttrs (
        k: v: {
          _class = "homeManager";
          _file = "${toString moduleLocation}#homeProfiles.${k}";
          imports = [ v ];
        }
      );
      description = ''
        Home Manager profiles.

        These are fully configured home manager configurations, ready to be imported by the nixos hodule.
      '';
    };
  };
}

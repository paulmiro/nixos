{
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
{
  imports = [
    (mkTransposedPerSystemModule {
      name = "ci";
      option = mkOption {
        type = types.lazyAttrsOf types.package;
        default = { };
        description = "derivations to be built on CI";
      };
      file = ./ci.flake.nix;
    })
  ];
  perSystem =
    {
      self',
      system,
      ...
    }:
    {
      ci =
        let
          ciHosts = filterAttrs (_name: host: host.config.paul.ci.enable) self.nixosConfigurations;
          ciHostsForSystem = filterAttrs (
            _name: host: system == host.config.nixpkgs.hostPlatform.system
          ) ciHosts;
          toplevelsForSystem = mapAttrs (_name: host: host.config.system.build.toplevel) ciHostsForSystem;
        in
        toplevelsForSystem // { devShell = self'.devShells.default; };
    };
}

{
  self,
  lib,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    ;
in
{
  perSystem =
    {
      self',
      system,
      ...
    }:
    {
      checks =
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

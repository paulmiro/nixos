{ pkgs, ... }:
let
  callPackage = pkgs.callPackage;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      custom_keycloak_themes = {
        keywind = callPackage ./keywind.nix { };
      };
    })
  ];
}

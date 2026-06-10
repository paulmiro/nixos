{
  config,
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    concatMapAttrs
    mkDefault
    genAttrs
    ;
in
{
  flake.homeConfigurations = genAttrs config.systems (
    system:
    (concatMapAttrs (
      profileName: profile:
      let
        configForUser =
          username:
          inputs.home-manager.homeManagerConfiguration {
            pkgs = inputs.nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
            extraSpecialArgs = {
              inherit self inputs;
              inherit (self) private versions;
            };
            modules = [
              profile
              {
                home.username = mkDefault username;
                home.homeDirectory = mkDefault (if username == "root" then "/root" else "/home/${username}");
              }
            ];
          };
      in
      {
        "${profileName}" = configForUser "paulmiro";
        "${profileName}-root" = configForUser "root";
      }
    ) self.homeProfiles)
  );
}

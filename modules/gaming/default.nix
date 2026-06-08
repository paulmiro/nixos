{ ... }:
{
  flake.nixosModules.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.paul.gaming;
    in
    {
      options.paul.gaming = {
        enable = lib.mkEnableOption "activate gaming programs and options";
      };

      config = lib.mkIf cfg.enable {

        # TODO fix for nixpkgs#513245
        nixpkgs.overlays = [
          (_: prev: {
            openldap = prev.openldap.overrideAttrs {
              doCheck = !prev.stdenv.hostPlatform.isi686;
            };
          })
        ];

        programs.steam = {
          enable = true;
          extraCompatPackages = [ (pkgs.proton-ge-bin.override { steamDisplayName = "GE-Proton-Nix"; }) ];
        };

        environment.systemPackages = with pkgs; [
          bottles
          (lutris.override {
            extraPkgs = pkgs: [
              # List package dependencies here
            ];
            extraLibraries = pkgs: [
              # List library dependencies here
            ];
          })
        ];
      };
    };
}

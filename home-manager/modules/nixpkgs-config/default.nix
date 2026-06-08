{ ... }:
{
  flake.homeModules.nixpkgs-config =
    {
      config,
      lib,
      ...
    }:
    {
      options = {
        paul.nixpkgs-config.enable = lib.mkEnableOption "nixpkgs config";
      };

      config = lib.mkIf config.paul.nixpkgs-config.enable {
        nixpkgs.config = import ./_nixpkgs-config.nix;
        xdg.configFile."nixpkgs/config.nix".source = ./_nixpkgs-config.nix;
      };
    };
}

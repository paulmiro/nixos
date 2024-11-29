{ config, lib, ... }:
with lib;
{
  options = {
    paul.nixpkgs-config.enable = lib.mkEnableOption "nixpkgs config";
  };

  config = mkIf config.paul.nixpkgs-config.enable {
    nixpkgs.config = import ./nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };
}

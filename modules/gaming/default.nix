{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.gaming;
in
{

  options.paul.gaming = {
    enable = mkEnableOption "activate gaming programs and options";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
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
}

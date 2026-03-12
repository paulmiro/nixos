{
  config,
  lib,
  nix-index-database,
  ...
}:
let
  cfg = config.paul.nix-index;
in
{
  imports = [
    nix-index-database.homeModules.default
  ];

  options.paul.nix-index = {
    enable = lib.mkEnableOption "enable nix-index";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = config.paul.dev.rust;
in
{
  options.paul.dev.rust = lib.mkEnableOption "enable rust";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      rust-analyzer
      bacon
    ];
  };
}

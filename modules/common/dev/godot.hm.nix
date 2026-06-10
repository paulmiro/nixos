{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = config.paul.dev.godot;
in
{
  options.paul.dev.godot = lib.mkEnableOption "enable godot";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      godot
      (if config.nixpkgs.config.allowUnfree then steam-run else steam-run-free)
    ];
  };
}

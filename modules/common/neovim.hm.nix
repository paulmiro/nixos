{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.neovim;
in
{
  options.paul.neovim = {
    enable = lib.mkEnableOption "enable neovim configuration";
    enableNeovide = lib.mkEnableOption "install neovide";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.neovim ] ++ lib.optional cfg.enableNeovide pkgs.neovide;
  };
}

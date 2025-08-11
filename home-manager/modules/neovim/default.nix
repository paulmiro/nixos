{
  config,
  lib,
  nix4nvchad,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.neovim;
in
{
  imports = [
    nix4nvchad.homeManagerModule
  ];

  options.paul.programs.neovim = {
    enable = lib.mkEnableOption "enable neovim configuration";
    enableNeovide = lib.mkEnableOption "install neovide";
  };

  config = lib.mkIf cfg.enable {
    programs.nvchad = {
      enable = true;
      backup = false;
    };

    home.packages = lib.mkIf cfg.enableNeovide [
      pkgs.neovide
    ];
  };
}

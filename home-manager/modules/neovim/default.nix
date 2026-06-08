{ inputs, ... }:
{
  flake.homeModules.neovim =
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
      imports = [
        inputs.nix4nvchad.homeManagerModule
      ];

      options.paul.neovim = {
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
    };
}

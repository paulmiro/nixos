{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.programs.starship;
in
{
  options.paul.programs.starship.enable = lib.mkEnableOption "enable starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings =
        (builtins.fromTOML (
          builtins.readFile (
            pkgs.fetchurl {
              url = "https://starship.rs/presets/toml/no-runtime-versions.toml";
              hash = "sha256-eUOdNK/941Kf5frs6G2TntRAcAisN8v1PrbVGMP11oY=";
            }
          )
        ))
        // {
          hostname = {
            format = "[$hostname]($style) ";
          };
          username = {
            format = "[$user]($style)@";
          };
          directory = {
            truncation_length = 10;
            truncation_symbol = "⋯/";
            substitutions = {
              "/run/media/${config.home.username}" = "󰕓";
            };
          };
        };
    };
  };
}

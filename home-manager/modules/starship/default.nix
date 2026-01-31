{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.starship;
in
{
  options.paul.starship = {
    enable = lib.mkEnableOption "enable starship";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings =
        (fromTOML (
          builtins.readFile (
            pkgs.fetchurl {
              url = "https://starship.rs/presets/toml/no-empty-icons.toml";
              hash = "sha256-PbPa6D93/D9UJOBKZ5tsCQZ/M9s5eGoAVceM0tAMs04=";
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

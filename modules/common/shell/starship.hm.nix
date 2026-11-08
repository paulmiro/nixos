{
  config,
  lib,
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
      presets = [
        "no-runtime-versions"
      ];
      settings = {
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

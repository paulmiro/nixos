{
  config,
  lib,
  starship-no-empty-icons,
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
      settings = (fromTOML (builtins.readFile "${starship-no-empty-icons}")) // {
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

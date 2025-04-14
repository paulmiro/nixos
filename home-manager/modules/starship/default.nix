{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.starship; in
{
  options.paul.programs.starship.enable = mkEnableOption "enable starship";

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings =
        (builtins.fromTOML (builtins.readFile (pkgs.fetchurl {
          url = "https://starship.rs/presets/toml/no-runtime-versions.toml";
          sha256 = "1s0503g44phc1lh9f804ppkgvh9xlvnqjizy1nlx5dm8igw9kfqp";
        }))) //
        {
          hostname = {
            format = "[$hostname]($style) ";
          };
          username = {
            format = "[$user]($style)@";
          };
          directory = {
            truncation_length = 10;
            truncation_symbol = "⋯/";
          };
        };
    };
  };
}

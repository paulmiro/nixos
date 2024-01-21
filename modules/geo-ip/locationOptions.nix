{ lib, pkgs, config, ... }:
with lib; let
  locationOptions = { config, ... }: {
    options = {
      geo-ip = mkEnableOption "enable geo-ip";
    };
    config.extraConfig = toString [
      (optional config.geo-ip ''
        if ($allowed_country = no) {
          return 444;
        }
      '')
    ];
  };
in
{
  options = {
    services.nginx.virtualHosts = with types;
      mkOption {
        type = attrsOf (submodule {
          options.locations =
            mkOption { type = attrsOf (submodule locationOptions); };
        });
      };
  };
  config = { };
}

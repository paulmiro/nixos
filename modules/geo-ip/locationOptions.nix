{
  lib,
  ...
}:
let
  locationOptions =
    { config, ... }:
    {
      options = {
        geo-ip = lib.mkEnableOption "enable geo-ip";
      };
      config.extraConfig = toString [
        (lib.optional config.geo-ip ''
          if ($allowed_country = no) {
            return 444;
          }
        '')
      ];
    };
in
{
  options = {
    services.nginx.virtualHosts =
      with lib.types;
      lib.mkOption {
        type = attrsOf (submodule {
          options.locations = lib.mkOption { type = attrsOf (submodule locationOptions); };
        });
      };
  };
  config = { };
}

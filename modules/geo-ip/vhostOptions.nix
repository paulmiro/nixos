{
  lib,
  pkgs,
  config,
  ...
}:
let
  vhostOptions =
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
    services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule vhostOptions);
    };
  };
  config = { };
}

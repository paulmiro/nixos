{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  vhostOptions =
    { config, ... }:
    {
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
    services.nginx.virtualHosts =
      with types;
      mkOption {
        type = types.attrsOf (types.submodule vhostOptions);
      };
  };
  config = { };
}

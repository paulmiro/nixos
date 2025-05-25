{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.paul.group.arr;
in
{

  options.paul.group.arr = {
    enable = mkEnableOption "activate group arr";
  };

  config = mkIf cfg.enable {

    users.groups.arr = {
      gid = 4200;
    };

  };
}

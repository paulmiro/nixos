{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.group.arr;
in
{

  options.paul.group.arr = {
    enable = lib.mkEnableOption "activate group arr";
  };

  config = lib.mkIf cfg.enable {

    users.groups.arr = {
      gid = 4200;
    };

  };
}

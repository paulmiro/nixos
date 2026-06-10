{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.group.transmission;
in
{
  options.paul.group.transmission = {
    enable = lib.mkEnableOption "activate group transmission";
  };

  config = lib.mkIf cfg.enable {
    users.groups.transmission = {
      gid = config.ids.gids.transmission; # 70
    };

    users.users.paulmiro.extraGroups = [ "transmission" ];
  };
}

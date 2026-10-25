{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.group.dump-dir;
in
{
  options.paul.group.dump-dir = {
    enable = lib.mkEnableOption "activate group dump-dir";
  };

  config = lib.mkIf cfg.enable {
    users.groups.dump-dir = {
      gid = 4000;
    };

    users.users.paulmiro.extraGroups = [ "dump-dir" ];
  };
}

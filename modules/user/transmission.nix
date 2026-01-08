{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.user.transmission;
in
{
  options.paul.user.transmission = {
    enable = lib.mkEnableOption "activate user transmission";
  };

  config = lib.mkIf cfg.enable {
    paul.group.transmission.enable = true;
    users.users.transmission = {
      description = "Transmission BitTorrent user";
      uid = config.ids.uids.transmission; # 70
      group = "transmission";
    };
  };
}

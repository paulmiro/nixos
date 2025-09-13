{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.readarr;
in
{
  options.paul.readarr = {
    enable = lib.mkEnableOption "activate readarr";
    openFirewall = lib.mkEnableOption "allow readarr port in firewall";
  };

  config = lib.mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableArr = true;

    users.users.readarr.uid = 8787;

    services.readarr = {
      enable = true;
      package =
        assert false;
        pkgs.readarr.overrideAttrs {
          # bookshelf fork does not do releases so here are the options:
          # - use Faustvil fork instead ( slightly wporse results)
          # - build bookshelf from source (use other arrs as examples)
          # - use bookshelf container
          # TODO override src
        };
      user = "readarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };
  };
}

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
    paul.group.transmission.enable = true;

    services.readarr = {
      enable = true;
      package =
        assert false;
        pkgs.readarr.overrideAttrs {
          # bookshelf fork does not do releases so here are the options:
          # - use Faustvil fork instead ( slightly worse results)
          # - build bookshelf from source (use other arrs as examples)
          # - use bookshelf container
          # TODO override src
        };
      group = "transmission";
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      config.services.readarr.settings.server.port
    ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.displaylink;
in
{
  options.paul.displaylink = {
    enable = lib.mkEnableOption "enable displaylink support";
  };

  config = lib.mkIf cfg.enable {
    # enable the driver
    services.xserver.videoDrivers = [ "displaylink" ];
    # auto-start the service
    systemd.services.dlm.wantedBy = [ "multi-user.target" ];
    # downloading this means agreeing to their EULA
    nixpkgs.overlays = [
      (self: super: {
        displaylink = super.displaylink.overrideAttrs {
          src = pkgs.fetchurl {
            name = "displaylink-620.zip";
            url = "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
            hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
          };
        };
      })
    ];

  };
}

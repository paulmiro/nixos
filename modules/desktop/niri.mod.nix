{
  config,
  lib,
  pkgs,

  inputs,
  ...
}:
let
  cfg = config.paul.niri;
  noctaliaPackage = pkgs.noctalia-shell;
  niriPackage = inputs.wrapper-modules.wrappers.niri.wrap {
    inherit pkgs;
    settings = {
      spawn-at-startup = [
        (lib.getExe noctaliaPackage)
      ];

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      input.keyboard.xkb.layout = "de";

      layout.gaps = 5;

      binds = {
        "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
        "Mod+Q".close-window = _: { };
        "Mod+S".spawn-sh = "${lib.getExe noctaliaPackage} ipc call launcher toggle";
      };
    };
  };
in
{
  options.paul.niri = {
    enable = lib.mkEnableOption "enable niri";
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true; # polkit
    services.gnome.gnome-keyring.enable = true; # secret service

    programs.niri = {
      enable = true;
      # package = niriPackage;
    };

    environment.systemPackages = [
      pkgs.noctalia-shell
    ];
  };
}

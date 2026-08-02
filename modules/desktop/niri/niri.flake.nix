{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      packages.noctalia-shell = pkgs.noctalia-shell;

      packages.niri =
        let
          noctalia = config.packages.noctalia-shell;
          noctaliaExe = lib.getExe noctalia;
        in
        inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;
          settings = {
            include = ./niri-config.kdl;

            binds = {
              "Mod+Return".spawn = lib.getExe pkgs.ghostty;
              "Mod+S".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
            };

            xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

            spawn-at-startup = [
              noctaliaExe
            ];
          };
        };

    };

  flake.nixosModules.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.paul.niri;
    in
    {
      options.paul.niri = {
        enable = lib.mkEnableOption "enable niri";
      };

      config = lib.mkIf cfg.enable {
        security.polkit.enable = true;
        services.gnome.gnome-keyring.enable = true;

        programs.niri = {
          enable = true;
          package = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.niri);
        };

        environment.systemPackages = [
          pkgs.noctalia-shell
        ];
      };
    };
}

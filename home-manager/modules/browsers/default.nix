{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}:
let
  cfg = config.paul.browsers;
in
{
  options.paul.browsers = {
    chromium = lib.mkEnableOption "enable ungoogled chromium";
    firefox = lib.mkEnableOption "enable firefox";
    tor = lib.mkEnableOption "enable tor browser";
    zen = lib.mkEnableOption "enable zen browser";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.chromium {
      home.packages = with pkgs; [
        ungoogled-chromium
      ];
    })
    (lib.mkIf cfg.firefox {
      programs = {
        firefox = {
          enable = true;
          package = (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { });
        };
      };
    })
    (lib.mkIf cfg.tor {
      home.packages = with pkgs; [
        tor-browser
      ];
    })
    (lib.mkIf cfg.zen {
      home.packages = with pkgs; [
        zen-browser.packages.${stdenv.hostPlatform.system}.default
      ];
    })
  ];
}

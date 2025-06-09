{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.common;
in
{
  options.paul.common = {
    enable = lib.mkEnableOption "contains configuration that is common to all systems";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    paul = {
      locale.enable = true;
      nix-common.enable = true;
      openssh.enable = true;
      user = {
        paulmiro.enable = true;
        root.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
    ];

    # to make sure clan vars can manage passwords correctly
    users.mutableUsers = false;
  };
}

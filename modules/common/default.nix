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
      home-manager.enable = true;

      locale.enable = true;
      nix-common.enable = true;
      openssh.enable = true;
      user = {
        paulmiro.enable = true;
        root.enable = true;
      };
    };

    # to make sure clan vars can manage passwords correctly
    users.mutableUsers = false;

    security.sudo.extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl *";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };
}

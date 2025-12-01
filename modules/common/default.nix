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

    security.sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
      '';
      extraRules = [
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

    # fixes "can't find terminal definition for xterm-ghostty"
    # taken and edited from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/terminfo.nix
    # some packages in there break, so i just include the ones i need
    environment.systemPackages = (
      map (x: x.terminfo) (
        with pkgs.pkgsBuildBuild;
        [
          alacritty
          foot
          ghostty
          kitty
          rio
          tmux
          wezterm
          yaft
        ]
      )
    );

    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    hardware.enableRedistributableFirmware = true;
  };
}

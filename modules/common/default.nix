{
  pkgs,
  lib,
  config,
  flake-self,
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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      dnsutils
      git
      wget
    ];

  };

}

{ pkgs, lib, config, flake-self, ... }:
with lib;
let cfg = config.paul.common;
in
{

  options.paul.common = {
    enable = mkEnableOption "contains configuration that is common to all systems";
  };

  config = mkIf cfg.enable {

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

    system.stateVersion = "23.05";

    lollypops.extraTasks = {
      rebuild-nosecrets = {
        desc = "Rebuild without deloying secrets";
        cmds = [ ];
        deps = [
          "deploy-flake"
          "rebuild"
        ];
      };
    };

  };

}

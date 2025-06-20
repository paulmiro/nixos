{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.user.root;
in
{
  options.paul.user.root = {
    enable = lib.mkEnableOption "activate user root";
  };

  config = lib.mkIf cfg.enable {
    users.users.root = {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMHjHjJ/vMoD3LId4IskuD9A6GwyTQXzt61IEq3/paul paulmiro@newton"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEom7NN1k9UCOTTiYsMBLqUK8BF8rjXTWAVQHSk/hwk paulmiro@hawking"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINirIGaLp4nLyJ4JUbCoknq5uqmp59uOfBrig0iW/mor paulmiro@morse"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINamsWVM0+zxXxUh5K1ww0GrdleakE3X8QSMJ+0b/btr paulmiro@better-laptop-paul-wsl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKn+lCU7J7iNEhsCVK8chXmqeGsIAlbqhwbY8Rq/bll paulmiro@bell-avf"
      ];
    };
  };
}

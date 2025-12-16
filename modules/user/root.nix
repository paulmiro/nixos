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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINirIGaLp4nLyJ4JUbCoknq5uqmp59uOfBrig0iW/mor paulmiro@morse"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINamsWVM0+zxXxUh5K1ww0GrdleakE3X8QSMJ+0b/btr paulmiro@leibniz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKn+lCU7J7iNEhsCVK8chXmqeGsIAlbqhwbY8Rq/bll paulmiro@bell-avf"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESZxtxQOpcoxKjJO5f6XlVDmUSG7ZYz1fN5dIqi/tur paulmiro@turing"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq7MvzwppeaeZKiAZD2ioW6MB7wLClX4H78kO72/bak paulmiro@backus"
      ];
    };
  };
}

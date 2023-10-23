{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [ ];

  };
}

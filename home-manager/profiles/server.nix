{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  config = {

    # Install these packages for my user
    home.packages = with pkgs; [ ];

  };
}

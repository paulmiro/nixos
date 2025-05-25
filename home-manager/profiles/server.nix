{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {

    # Install these packages for my user
    home.packages = with pkgs; [ ];

  };
}

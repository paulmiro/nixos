{
  pkgs,
  ...
}:
{
  config = {
    paul = {
      gnome-settings.enable = true;

      browsers = {
        zen = true;
      };
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      cockatrice
      discord
      mpv
      obs-studio
      spotify
    ];
  };
}

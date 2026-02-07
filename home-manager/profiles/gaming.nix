{
  pkgs,
  lib,
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

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = lib.mkForce [
          "zen.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.Nautilus.desktop"
          "steam.desktop"
        ];
      };
    };
  };
}

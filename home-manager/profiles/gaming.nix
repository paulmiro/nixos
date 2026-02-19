{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    paul = {
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

    dconf.settings = lib.mkIf config.paul.gnome-settings.enable {
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

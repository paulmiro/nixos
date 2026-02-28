{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.paul.filebrowser.config = lib.mkOption {
    type = lib.types.attrs;
    default = {
      server = {
        externalUrl = "https://${config.paul.private.domains.filebrowser}";
        port = 19105;

        cacheDir = "/var/cache/filebrowser";
        database = "database.db";
      };

      integrations = {
        media = {
          ffmpegPath = "${pkgs.ffmpeg}/bin";
          extractEmbeddedSubtitles = false;
        };
      };

      sources = [
        {
          name = "Arr";
          path = "/mnt/arr";
          config = {
            denyByDefault = true;
          };
        }
      ];
    };
    description = "filebrowser-quantum config";
  };
}

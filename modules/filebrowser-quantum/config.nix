{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.paul.filebrowser-quantum.config = lib.mkOption {
    type = lib.types.attrs;
    default = {
      server = {
        externalDomain = config.paul.private.domains.filebrowser-quantum;
        port = 19105;

        cacheDir = "cache";
        database = "database.db";
      };

      integrations = {
        media = {
          # TODO: do we want this?
          ffmpegPath = "${pkgs.ffmpeg}/bin";
          extractEmbeddedSubtitles = false;
        };
      };
    };
    description = "filebrowser-quantum config";
  };
}

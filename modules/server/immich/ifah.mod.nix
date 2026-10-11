{
  config,
  lib,
  inputs,

  private,
  ...
}:
let
  cfg = config.paul.immich.ifah;
  serviceName = "immich-federation-at-home";
in
{
  imports = [
    inputs.ifah.nixosModules.default
  ];

  options.paul.immich.ifah = {
    enable = lib.mkEnableOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.${serviceName} = {
      enable = true;
      environmentFile = config.clan.core.vars.generators.${serviceName}.files.env.path;
      settings = {
        import_server_url = "https://${private.domains.immich}";
        import_api_key_env = "API_KEY";
        import_album = "Japan 2026";
        interval = "1h";

        tags = [
          "ifah"
        ];

        jobs.jp_b = {
          export_album_url_env = "URL_JP_B";
          export_album_password_env = "PASSWORD_JP_B";
          tags = [
            "ifah-jp"
            "ifah-b"
            "ifah-jp-b"
          ];
        };
        jobs.jp_l = {
          export_album_url_env = "URL_JP_L";
          export_album_password_env = "PASSWORD_JP_L";
          tags = [
            "ifah-jp"
            "ifah-l"
            "ifah-jp-l"
          ];
        };
      };
    };

    clan.core.vars.generators.${serviceName} = rec {
      prompts.api_key.description = "Api Key for import";

      prompts.url_jp_b.description = "URL for export album jp_b";
      prompts.password_jp_b.description = "Password for export album jp_b";

      prompts.url_jp_l.description = "URL for export album jp_l";
      prompts.password_jp_l.description = "Password for export album jp_l";

      files.env.secret = true;

      script = ''
        echo "
        ${lib.concatMapStringsSep "\n" (name: ''${lib.toUpper name}=$(cat "$prompts/${name}")'') (
          lib.attrNames prompts
        )}
        " > $out/env
      '';
    };
  };
}

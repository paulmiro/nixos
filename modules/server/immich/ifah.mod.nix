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
        interval = "1h";

        tags = [
          "ifah"
        ];
      };
    };

    clan.core.vars.generators.${serviceName} = rec {
      prompts.api_key.description = "Api Key for import";
      prompts.api_key.persist = true;

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

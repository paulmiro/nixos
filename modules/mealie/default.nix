{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.mealie;
in
{
  options.paul.mealie = {
    enable = lib.mkEnableOption "Mealie, a recipe manager and meal planner";

    package = lib.mkPackageOption pkgs "mealie" { };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://mealie.${config.paul.private.domains.base}";
      description = "Base URL of the Mealie service.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9925;
      description = "Port on which to serve the Mealie service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/mealie";
      description = "Directory where Mealie stores its data.";
    };

    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = {
        ALLOW_SIGNUP = "false";
      };
      description = ''
        Configuration of the Mealie service.

        See [the mealie documentation](https://nightly.mealie.io/documentation/getting-started/installation/backend-config/) for available options and default values.
      '';
      example = {
        ALLOW_SIGNUP = "false";
      };
    };

    credentialsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/mealie-credentials.env";
      description = ''
        File containing credentials used in mealie such as {env}`POSTGRES_PASSWORD`
        or sensitive LDAP options.

        Expects the format of an `EnvironmentFile=`, as described by {manpage}`systemd.exec(5)`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.mealie = {
      description = "Mealie, a self hosted recipe manager an^d meal planner";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PRODUCTION = "true";
        ALEMBIC_CONFIG_FILE = "${cfg.package}/config/alembic.ini";
        API_PORT = toString cfg.port;
        BASE_URL = "${cfg.baseUrl}:${cfg.port}";
        DATA_DIR = cfg.dataDir;
        CRF_MODEL_PATH = "${cfg.dataDir}/model.crfmodel";
      } // (builtins.mapAttrs (_: val: toString val) cfg.settings);

      serviceConfig = {
        DynamicUser = true;
        User = "mealie";
        ExecStartPre = "${cfg.package}/libexec/init_db";
        ExecStart = "${lib.getExe cfg.package} -b 127.0.0.1:${builtins.toString cfg.port}";
        EnvironmentFile = lib.mkIf (cfg.credentialsFile != null) cfg.credentialsFile;
        StateDirectory = "mealie";
        StandardOutput = "journal";
      };
    };
  };
}

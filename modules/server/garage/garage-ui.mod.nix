{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.garage;
  ports = import ./ports.nix;
in
{
  options.paul.garage = {
    enableAdminUI = lib.mkEnableOption "Garage Admin UI";
  };

  config = lib.mkIf cfg.enableAdminUI {

    virtualisation.oci-containers.containers.garage-ui = {
      serviceName = "garage-ui-docker";
      image = "noooste/garage-ui:latest";
      volumes = [
        "/etc/garage.toml:/etc/garage.toml:ro"
      ];
      extraOptions = [
        # needs to access [::1]
        "--network=host"
      ];
      environment = {
        GARAGE_UI_SERVER_PORT = toString ports.admin_ui;
        GARAGE_UI_GARAGE_TOML = "/etc/garage.toml";
        GARAGE_UI_AUTH_JWT_PRIVATE_KEY = ""; # auto-generate on each startup
        GARAGE_UI_AUTH_ADMIN_ENABLED = "true";
        GARAGE_UI_AUTH_ADMIN_USERNAME = "admin";
      };
      environmentFiles = [
        config.clan.core.vars.generators.garage-ui.files.env.path
      ];
    };

    paul.tailscale.services.garage.port = ports.admin_ui;

    clan.core.vars.generators.garage-ui = {
      prompts.admin-password.description = "Garage UI Admin Password (see bw)";
      prompts.admin-password.type = "hidden";
      prompts.admin-password.persist = true;

      files.env.secret = true;

      dependencies = [
        "garage"
      ];

      runtimeInputs = [ pkgs.openssl ];

      script = ''
        source $in/garage/env
        echo "
        GARAGE_UI_GARAGE_ADMIN_TOKEN=$GARAGE_ADMIN_TOKEN
        GARAGE_UI_AUTH_ADMIN_PASSWORD="$(cat $prompts/admin-password)"
        " > $out/env
      '';
    };

    assertions = [
      {
        assertion = cfg.enable;
        message = "garage-ui requires garage to be enabled";
      }
    ];
  };
}

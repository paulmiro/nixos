{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.umlautadaptarr;
  serviceName = "umlautadaptarr-docker";
in
{
  options.paul.umlautadaptarr = {
    enable = lib.mkEnableOption "enable umlautadaptarr";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."umlautadaptarr" = {
      inherit serviceName;
      image = "pcjones/umlautadaptarr:latest";
      environment = {
        "SONARR__ENABLED" = "true";
        "SONARR__HOST" = "http://${config.networking.hostName}:8989";
        "RADARR__ENABLED" = "true";
        "RADARR__HOST" = "http://${config.networking.hostName}:7878";
      };
      environmentFiles = [ config.clan.core.vars.generators.umlautadaptarr.files.env.path ];
      ports = [
        "5006:5006"
      ];
    };

    networking.firewall.interfaces.docker0.allowedTCPPorts = [
      config.services.sonarr.settings.server.port
      config.services.radarr.settings.server.port
    ];

    clan.core.vars.generators.umlautadaptarr = {
      prompts.sonarr-api-key.description = "Sonarr API Key";
      prompts.sonarr-api-key.type = "hidden";
      prompts.sonarr-api-key.persist = false;

      prompts.radarr-api-key.description = "Radarr API Key";
      prompts.radarr-api-key.type = "hidden";
      prompts.radarr-api-key.persist = false;

      files.env.secret = true;

      script = ''
        echo "
        SONARR__APIKEY="$(cat $prompts/sonarr-api-key)"
        RADARR__APIKEY="$(cat $prompts/radarr-api-key)"
        " > $out/env
      '';
    };

  };
}

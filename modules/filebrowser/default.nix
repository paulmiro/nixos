{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.filebrowser;
in
{
  options.paul.filebrowser = {
    enable = lib.mkEnableOption "activate filebrowser";
    containerVersion = lib.mkOption {
      type = lib.types.str;
      default = "8.0.0"; # TODO
      description = "filebrowser container version";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 80; # TODO
      description = "filebrowser port";
    };

    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "filebrowser config";
    };

    openTailscaleFirewall = lib.mkEnableOption "open firewall for filebrowser";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    users.groups.filebrowser = {
      # TODO gid?
    };

    users.users.filebrowser = {
      # TODO uid?
      description = "filebrowser user";
      group = "filebrowser";
      extraGroups = lib.mkIf config.paul.groups.transmission.enable [ "transmission" ];
    };

    virtualisation.oci-containers.containers.filebrowser = {
      serviceName = "filebrowser-docker";
      image = "ghcr.io/gtsteffaniak/filebrowser:${cfg.containerVersion}";
      user = "filebrowser:filebrowser";
      volumes = [
        "/etc/filebrowser/config.yaml:/home/filebrowser/data/config.yaml"
        "/var/lib/filebrowser:/home/filebrowser"

        "/mnt/arr:/srv/arr:ro"
      ];
      ports = [
        "${toString cfg.port}:80/tcp"
      ];
      environment = {
        FILEBROWSER_CONFIG = "data/config.yaml";
        TZ = config.time.timeZone;
      };
      environmentFiles = [
        config.clan.core.vars.generators.filebrowser.files.env.path
      ];
    };

    paul.filebrowser.config = {
      # TODO
    };

    environment.etc = {
      "filebrowser/config.yaml" = {
        source = lib.generators.toYAML cfg.config;
      };
    };

    clan.core.vars.generators.filebrowser = {
      prompts.admin-password.description = "Filebrowser Admin Password (see bw)";
      prompts.admin-password.type = "hidden";
      prompts.admin-password.persist = false;

      files.env.secret = true;
      files.env.owner = "filebrowser"; # TODO: make filebrowser run as paulmiro?

      script = ''
        echo "
        FILEBROWSER_ADMIN_PASSWORD="$(cat $prompts/admin-password)"
        " > $out/env
      '';
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      cfg.port
    ];
  };

}

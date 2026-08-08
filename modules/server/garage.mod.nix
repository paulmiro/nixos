{
  config,
  lib,
  pkgs,

  private,
  ...
}:
let
  cfg = config.paul.garage;
  package = pkgs.garage_2;
  domains = {
    s3 = private.domains.garage-s3;
    web = private.domains.garage-web;
  };
  ports = {
    s3 = 3900;
    rpc = 3901;
    web = 3902;
    admin = 3903;
    admin_ui = 19113;
  };
in
{
  options.paul.garage = {
    enable = lib.mkEnableOption "Garage";
  };

  config = lib.mkIf cfg.enable {

    services.garage = {
      enable = true;

      inherit package;

      settings = {
        replication_factor = 1;
        db_engine = "sqlite";
        compression_level = "none"; # zfs handles compression
        disable_scrub = true; # zfs handles scrub

        rpc_bind_addr = "[::1]:${toString ports.rpc}";
        rpc_public_addr = "[::1]:${toString ports.rpc}";

        s3_api = {
          api_bind_addr = "[::1]:${toString ports.s3}";
          root_domain = domains.s3;
          s3_region = "de";
        };

        s3_web = {
          bind_addr = "[::1]:${toString ports.web}";
          root_domain = domains.web;
        };

        admin = {
          api_bind_addr = "[::1]:${toString ports.admin}";
          metrics_require_token = true;
          admin_token = "dummy"; # garage-ui requires this to exist in the config file. gets overwritten by env
        };
      };

      environmentFile = config.clan.core.vars.generators.garage.files.env.path;
    };

    systemd.services.garage.serviceConfig = {
      DynamicUser = false;
      ProtectSystem = "strict";
      User = "garage";
      Group = "garage";
      ReadWritePaths = [
        "/var/lib/garage"
      ];
    };

    users.users.garage = {
      isSystemUser = true;
      group = "garage";
      home = "/var/lib/garage/meta";
    };
    users.groups.garage = { };
    users.users.paulmiro.extraGroups = [ "garage" ];

    systemd.tmpfiles.settings."10-garage" =
      let
        ownedDir.d = {
          age = "-";
          mode = "0750";
          user = "garage";
          group = "garage";
        };
      in
      {
        "/var/lib/garage" = ownedDir;
        "/var/lib/garage/meta" = ownedDir;
        "/var/lib/garage/data" = ownedDir;
      };

    clan.core.vars.generators.garage = {
      files.env.secret = true;

      runtimeInputs = [ pkgs.openssl ];

      script = ''
        echo "
        GARAGE_ADMIN_TOKEN="$(openssl rand -hex 32)"
        GARAGE_METRICS_TOKEN="$(openssl rand -hex 32)"
        GARAGE_RPC_SECRET="$(openssl rand -hex 32)"
        " > $out/env
      '';
    };

    environment.systemPackages = [
      # secrets are not in the config file, so we wrap the package for cli usage
      (pkgs.writeScriptBin "garage" ''
        set -euo pipefail
        source ${config.clan.core.vars.generators.garage.files.env.path}
        export GARAGE_ADMIN_TOKEN GARAGE_METRICS_TOKEN GARAGE_RPC_SECRET
        ${lib.getExe package} "$@"
      '')
    ];

    security.acme = {
      certs."${domains.s3}" = {
        domain = domains.s3;
        extraDomainNames = [ "*.${domains.s3}" ];
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.clan.core.vars.generators.cloudflare-dyndns.files.env.path;
      };
    };

    services.nginx.virtualHosts."${domains.s3}" = {
      serverAliases = [ "*.${domains.s3}" ];
      enableACME = false;
      useACMEHost = domains.s3;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString ports.s3}";
        enableGeoIP = true;
        proxyWebsockets = true;
      };
    };

    # TODO nginx+acme for web

    disko.devices.zpool = {
      blitz.datasets."apps/garage_meta" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/garage/meta";
        options.mountpoint = "/var/lib/garage/meta";
      };
      tank.datasets."garage_data" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/garage/data";
        options.mountpoint = "/var/lib/garage/data";
        options.compression = "lz4";
        options."com.sun:auto-snapshot" = "true";
      };
    };

    clan.core.state.garage = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/garage/meta"
        "/var/lib/garage/data"
      ];
      servicesToStop = [ "garage.service" ];
    };

    ### Admin Web UI ###

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
  };
}

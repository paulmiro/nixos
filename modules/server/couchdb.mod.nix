{
  config,
  lib,
  pkgs,

  private,
  ...
}:
let
  cfg = config.paul.couchdb;
  port = 5984;
  domain = private.domains.couchdb;
in
{
  options.paul.couchdb = {
    enable = lib.mkEnableOption "Enable couchdb";
  };

  config = lib.mkIf cfg.enable {
    services.couchdb = {
      enable = true;
      extraConfig = {
        couchdb = {
          single_node = true; # auto-create the required internal databases
          max_document_size = 50000000; # 50M
        };
        chttpd = {
          bind_address = "::1";
          inherit port;
          require_valid_user_except_for_up = true;
          max_http_request_size = 4294967296; # 4G
          enable_cors = true;
        };
        cors = {
          credentials = true;
          origins = "app://obsidian.md,capacitor://localhost,http://localhost";
        };
      };
      extraConfigFiles = [ config.clan.core.vars.generators.couchdb.files."secrets.ini".path ];
    };

    services.nginx.virtualHosts."${domain}" = {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
        enableGeoIP = true;
      };
    };

    clan.core.vars.generators.couchdb = {
      prompts.admin-password.description = "CouchDB Admin Password";

      files."secrets.ini".secret = true;
      files."secrets.ini".owner = "couchdb";
      files."secrets.ini".mode = "0400";

      script = ''
        cat << EOF > $out/secrets.ini
        [admins]
        admin = $(cat $prompts/admin-password)
        EOF
      '';
    };

    systemd.tmpfiles.settings."10-couchdb" = {
      "/var/lib/couchdb".d = {
        age = "-";
        mode = "0750";
        user = "couchdb";
        group = "couchdb";
      };
    };

    disko.devices.zpool = {
      blitz.datasets."apps/couchdb" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/couchdb";
        options.mountpoint = "/var/lib/couchdb";
      };
    };

    clan.core.state.couchdb = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/couchdb"
      ];
      servicesToStop = [ "couchdb.service" ];
    };
  };
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.paul.nginx;
in
{

  imports = [
    ./locationOptions.nix
    ./vhostOptions.nix
  ];

  options.paul.nginx = {
    enableGeoIP = mkEnableOption "enable GeoIP";
    licenseKeyFile = mkOption {
      type = types.path;
      default = "/run/keys/maxmind-license-key";
      description = "Path to the MaxMind license key file";
    };
    databaseDirectory = mkOption {
      type = types.path;
      default = "/var/lib/GeoIP";
      description = "Directory where the GeoIP database is stored";
    };
  };

  config = mkIf cfg.enableGeoIP {

    # when Nginx is enabled, enable the GeoIP updater service
    services.geoipupdate = mkIf cfg.enable {
      enable = true;
      interval = "weekly";
      settings = {
        EditionIDs = [ "GeoLite2-Country" ];
        AccountID = 767585;
        LicenseKey = cfg.licenseKeyFile;
        DatabaseDirectory = cfg.databaseDirectory;
      };
    };

    # this user only exists to give the user the keys group for access to /run/keys
    users.users.geoip = {
      uid = 63606;
      group = "geoip";
      isSystemUser = true;
      home = cfg.databaseDirectory;
      extraGroups = [ "keys" ];
    };

    users.groups.geoip = { };

    # this breaks on first deploy, because the user does not exist yet
    # to fix this, three steps are needed:
    # 1. delploy only the user config
    # 2. deploy only the secret (perhaps by activating this module entirely and using {hostname}:deploy-secrets)
    # 3. deploy the full config
    lollypops.secrets.files."maxmind-license-key" = {
      cmd = "rbw get maxmind-license-key";
      path = cfg.licenseKeyFile;
      owner = "geoip";
    };

    # build nginx with geoip2 module
    services.nginx = {
      package = pkgs.nginxStable.override (oldAttrs: {
        modules = with pkgs.nginxModules; [ geoip2 ];
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.libmaxminddb ];
      });
      appendHttpConfig = toString (
        [
          # we want to load the geoip2 module in our http config, pointing to the database we are using
          # country iso code is the only data we need
          ''
            geoip2 ${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-Country.mmdb {
              $geoip2_data_country_iso_code country iso_code;
            }
          ''
          # we want to allow only requests from specific countries
          # if a request is not from such a country, we return no, which will result in a 403
          ''
            map $geoip2_data_country_iso_code $allowed_country {
              default no;
              DE yes;
              ES yes;
              FR yes;
              GB yes;
              IT yes;
              NL yes;
              JP yes;
              LU yes;
              PE yes; # Peru, für Joshua
            }
          ''
        ]
      );
    };

  };
}

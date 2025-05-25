{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.nginx;
in
{

  imports = [
    ./locationOptions.nix
    ./vhostOptions.nix
  ];

  options.paul.nginx = with lib; {
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

  config = lib.mkIf cfg.enableGeoIP {

    # when Nginx is enabled, enable the GeoIP updater service
    services.geoipupdate = lib.mkIf cfg.enable {
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
    # 1. comment out this secrets block and deploy, ignore the error
    # 2. uncomment and deploy again
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
      appendHttpConfig = toString ([
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
            AT yes; # for some reason morse gets identified as austria
            ES yes;
            FR yes;
            GB yes;
            IT yes;
            NL yes;
            JP yes;
            LU yes;
            US yes;
          }
        ''
      ]);
    };

  };
}

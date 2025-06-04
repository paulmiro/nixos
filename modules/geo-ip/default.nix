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
        LicenseKey = config.clan.core.vars.generators.maxmind-license-key.files.key.path;
        DatabaseDirectory = cfg.databaseDirectory;
      };
    };

    clan.core.vars.generators.maxmind-license-key = {
      prompts.key.description = "MaxMind License Key (see bw)";
      prompts.key.type = "hidden";
      prompts.key.persist = false;

      files.key.secret = true;
      files.key.owner = "geoip";

      share = true;

      script = "cp $prompts/key $out/key";
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

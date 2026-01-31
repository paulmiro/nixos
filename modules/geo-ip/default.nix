{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.geo-ip;
  enabledVhosts = (
    builtins.filter (vhost: vhost.value.enableGeoIP) (
      lib.attrsToList config.services.nginx.virtualHosts
    )
  );
  enabledLocations = (
    builtins.concatMap (
      vhost: builtins.filter (loc: loc.value.enableGeoIP) (lib.attrsToList vhost.value.locations)
    ) (lib.attrsToList config.services.nginx.virtualHosts)
  );
  enable =
    (!cfg.forceDisable)
    # auto-enable when at least one vhost or location has the option set
    && ((builtins.length enabledVhosts) != 0 || (builtins.length enabledLocations) != 0);
in
{
  options.paul.geo-ip = {
    forceDisable = lib.mkEnableOption "force disable geo-ip systemwide";
  };

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options = {
            enableGeoIP = lib.mkEnableOption "enable geo-ip for this vhost";
          };
          config.extraConfig = toString [
            (lib.optional (config.enableGeoIP && !cfg.forceDisable) ''
              if ($allowed_country = no) {
                return 444;
              }
            '')
          ];

          options.locations = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { config, ... }:
                {
                  options = {
                    enableGeoIP = lib.mkEnableOption "enable geo-ip";
                  };
                  config.extraConfig = toString [
                    (lib.optional (config.enableGeoIP && !cfg.forceDisable) ''
                      if ($allowed_country = no) {
                        return 444;
                      }
                    '')
                  ];
                }
              )
            );
          };
        }
      )
    );
  };

  config = lib.mkIf enable {

    services.geoipupdate = {
      enable = true;
      interval = "weekly";
      settings = {
        EditionIDs = [ "GeoLite2-Country" ];
        AccountID = 767585;
        LicenseKey = config.clan.core.vars.generators.maxmind-license-key.files.key.path;
      };
    };

    clan.core.vars.generators.maxmind-license-key = {
      prompts.key.description = "MaxMind License Key (see bw)";
      prompts.key.type = "hidden";
      prompts.key.persist = false;

      files.key.secret = true;

      share = true;

      script = "cp $prompts/key $out/key";
    };

    # build nginx with geoip2 module
    services.nginx = {
      package = pkgs.nginxStable.override (oldAttrs: {
        modules = with pkgs.nginxModules; [ geoip2 ];
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.libmaxminddb ];
      });
      appendHttpConfig = toString [
        # we want to load the geoip2 module in our http config, pointing to the database we are using
        # the country iso code is the only data we need
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
            AU yes;
          }
        ''
      ];
    };
  };
}

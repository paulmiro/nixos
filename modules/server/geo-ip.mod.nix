{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.geo-ip;
  enabledVhosts = builtins.filter (vhost: vhost.value.enableGeoIP) (
    lib.attrsToList config.services.nginx.virtualHosts
  );
  enabledLocations = builtins.concatMap (
    vhost: builtins.filter (loc: loc.value.enableGeoIP) (lib.attrsToList vhost.value.locations)
  ) (lib.attrsToList config.services.nginx.virtualHosts);
  enable =
    (!cfg.forceDisable)
    # auto-enable when at least one vhost or location has the option set
    && ((builtins.length enabledVhosts) != 0 || (builtins.length enabledLocations) != 0);

  mkAclName = countries: lib.toLower (lib.concatStringsSep "_" countries);

  allCountryLists = lib.unique (
    (map (vhost: vhost.value.geoIpCountries) enabledVhosts)
    ++ (map (loc: loc.value.geoIpCountries) enabledLocations)
  );

  acls = map (countries: {
    name = mkAclName countries;
    countries = countries;
  }) allCountryLists;

  defaultCountries = [
    "AT"
    "AU"
    "DE"
    "DK"
    "ES"
    "FR"
    "GB"
    "IT"
    "JP"
    "LU"
    "NL"
    "US"
  ];
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
            geoIpCountries = lib.mkOption {
              description = "List of countries to allow requests from";
              type = lib.types.listOf lib.types.str;
              default = defaultCountries;
              apply = it: lib.naturalSort (lib.unique it);
            };
          };

          config = lib.mkMerge [
            # we cannot use `lib.mkIf enable` here because of infinite recursion
            (lib.mkIf (!cfg.forceDisable) {
              # this is added to all vhosts, regardless of enableGeoIP,
              # because we cannot determine if a location has it set
              extraConfig = ''
                error_page 452 =403 @geoblocked;
              '';
              locations."@geoblocked" = {
                root = ./.;
                tryFiles = "/geoblocked.html =404";
                extraConfig = ''
                  internal;
                  default_type text/html;
                '';
              };
            })
            (lib.mkIf (config.enableGeoIP && !cfg.forceDisable) {
              extraConfig = ''
                set $geo_acl ${mkAclName config.geoIpCountries};

                if ($geo_blocked) {
                  return 452;
                }
              '';
            })
          ];

          options.locations = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { config, ... }:
                {
                  options = {
                    enableGeoIP = lib.mkEnableOption "enable geo-ip";
                    geoIpCountries = lib.mkOption {
                      description = "List of countries to allow requests from";
                      type = lib.types.listOf lib.types.str;
                      default = defaultCountries;
                      apply = it: lib.naturalSort (lib.unique it);
                    };
                  };

                  config = lib.mkIf (config.enableGeoIP && !cfg.forceDisable) {
                    extraConfig = ''
                      set $geo_acl ${mkAclName config.geoIpCountries};

                      if ($geo_blocked) {
                        return 452;
                      }
                    '';
                  };
                }
              )
            );
          };
        }
      )
    );
  };

  config = lib.mkMerge [
    (lib.mkIf enable {
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
        prompts.key.persist = true;

        share = true;
      };

      # build nginx with geoip2 module
      services.nginx = {
        additionalModules = with pkgs.nginxModules; [ geoip2 ];
        appendHttpConfig = ''
          geoip2 ${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-Country.mmdb {
            auto_reload 60m;
            $geoip2_data_country_iso_code country iso_code;
          }

          map "$geo_acl:$geoip2_data_country_iso_code" $geo_blocked {
            default 1;

            # Disable GeoIP blocking for this location/profile
            ~^off: 0;

          ${lib.concatStringsSep "\n" (
            map (acl: ''
                # Profile: ${acl.name}
              ${lib.concatStringsSep "  \n" (map (country: "  ${acl.name}:${country} 0;") acl.countries)}
            '') acls
          )}
          }
        '';
      };
    })

    (lib.mkIf cfg.forceDisable {
      warnings = ''
        `paul.geo-ip.forceDisable` is only meant to temporarily disable the module.
      '';
    })
  ];
}

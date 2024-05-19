{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.paul.homepage-dashboard;
in
{

  options.paul.homepage-dashboard = {
    enable = mkEnableOption "activate homepage";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow homepage port in firewall";
    };
    enableNginx = mkEnableOption "activate nginx";
    domain = mkOption {
      type = types.str;
      default = "dash.***REMOVED***";
      description = "domain for homepage";
    };
    port = mkOption {
      type = types.port;
      default = 8082;
      description = "port for homepage";
    };
    environmentFile = mkOption {
      type = types.path;
      default = "/run/keys/homepage.env";
      description = "path to environment file";
    };
  };


  config = mkIf cfg.enable (mkMerge [
    {
      services.homepage-dashboard =
        {
          enable = true;
          openFirewall = cfg.openFirewall;
          listenPort = cfg.port;
          environmentFile = cfg.environmentFile;

          settings = {
            # todo use something like for a different image every time "https://source.unsplash.com/1920x1080/?nature,water";
            background = {
              image = "https://source.unsplash.com/PvgqqicSLvA";
              blur = "sm";
              brightness = 90;
              opacity = 80;
            };
            cardBlur = "md";
            theme = "dark";
            color = "stone";
            disableCollapse = true;
            useEqualHeights = true;
            headerStyle = "clean";
            target = "_blank";
            hideVersion = true;
            layout = [
              {
                Calendar = {
                  header = false;
                  style = "column";
                };
              }
              {
                MainBookmarks = {
                  header = false;
                  style = "column";
                };
              }
              {
                Media = {
                  style = "row";
                  columns = 4;
                };
              }
              {
                "Arr Stack" = {
                  style = "row";
                  columns = 4;
                };
              }
            ];
          };

          widgets = [
            {
              resources = {
                cpu = true;
                memory = true;
              };
            }
            {
              search = {
                provider = "duckduckgo";
                target = "_blank";
              };
            }
            /* # this requires a click on the widget to get the location permissions, wich is really annoying
            {
              openmeteo = {
                units = "metric";
                cache = "5";
              };
            }#
            */
          ];

          bookmarks = [
            {
              MainBookmarks = [
                {
                  "File Browser" = {
                    abbr = "FB";
                    icon = "filebrowser.png";
                    href = "https://***REMOVED***";
                    description = "File Browser";
                  };
                }
              ];
            }
          ];

          services = [
            {
              Calendar = [
                {
                  Calendar = {
                    widget = {
                      type = "calendar";
                      firstDayInWeek = "monday";
                      view = "monthly";
                      maxEvents = 10;
                      showTime = true;
                      integrations = [
                        {
                          type = "sonarr";
                          service_group = "Arr Stack";
                          service_name = "Sonarr";
                          params.unmonitored = false;
                        }
                        {
                          type = "radarr";
                          service_group = "Arr Stack";
                          service_name = "Radarr";
                          params.unmonitored = false;
                        }
                      ];
                    };
                  };
                }
                /*
                {
                  UptimeKuma = {
                    widget = {
                      type = "uptimekuma";
                      url = "http://uptime-kuma:3001";
                      slug = "homepage-dashboard";
                    };
                  };
                }
                */
              ];
            }
            {
              Media = [
                {
                  Jellyfin = {
                    icon = "jellyfin.png";
                    href = "https://${config.paul.jellyfin.domain}";
                    description = "Media Library";
                    widget = {
                      type = "jellyfin";
                      url = "https://${config.paul.jellyfin.domain}";
                      key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                      enableBlocks = true;
                      enableNowPlaying = true;
                      enableUser = true;
                      showEpisodeNumber = true;
                      expandOneStreamToTwoRows = true;
                    };
                  };
                }
                {
                  Immich = {
                    icon = "immich.png";
                    href = "https://${config.paul.immich.domain}";
                    description = "Photos";
                    widget = {
                      type = "immich";
                      url = "https://${config.paul.immich.domain}";
                      key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
                    };
                  };
                }
                {
                  TrueNAS = {
                    icon = "truenas.png";
                    href = "https://turing";
                    description = "Storage";
                    widget = {
                      type = "truenas";
                      url = "https://turing";
                      key = "{{HOMEPAGE_VAR_TRUENAS_API_KEY}}";
                      enablePools = true;
                    };
                  };
                }
              ];
            }
            {
              "Arr Stack" = [

                {
                  Jellyseerr = {
                    icon = "jellyseerr.png";
                    href = "https://${config.paul.jellyseerr.domain}";
                    description = "Movie and TV Show Requests";
                    widget = {
                      type = "jellyseerr";
                      url = "https://${config.paul.jellyseerr.domain}";
                      key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                    };
                  };
                }
                {
                  Radarr = {
                    icon = "radarr.png";
                    href = "http://hawking:7878";
                    description = "Movie Management";
                    widget = {
                      type = "radarr";
                      url = "http://hawking:7878";
                      key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                      enableQueue = true;
                    };
                  };
                }
                {
                  Sonarr = {
                    icon = "sonarr.png";
                    href = "http://hawking:8989";
                    description = "TV Show Management";
                    widget = {
                      type = "sonarr";
                      url = "http://hawking:8989";
                      key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                      enableQueue = true;
                    };
                  };
                }
                {
                  Prowlarr = {
                    icon = "prowlarr.png";
                    href = "http://hawking:9696";
                    description = "Indexer Management";
                    widget = {
                      type = "prowlarr";
                      url = "http://hawking:9696";
                      key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                    };
                  };
                }
                {
                  Transmission = {
                    icon = "transmission.png";
                    href = "http://turing:9091";
                    description = "Torrent Client";
                    widget = {
                      type = "transmission";
                      url = "http://turing:9091";
                    };
                  };
                }
              ];
            }

          ];
        };

      systemd.services.homepage-dashboard.serviceConfig.user = "homepage-dashboard";

      users.users.homepage-dashboard = {
        isSystemUser = true;
        group = "homepage-dashboard";
        extraGroups = [ "keys" ];
      };
      users.groups.homepage-dashboard = { };

      # homepage seems to cache this file somehow, it may sometimes be necessary to reboot for changes to take effect
      lollypops.secrets.files."homepage-environment" = {
        cmd = ''
          echo "
          HOMEPAGE_VAR_JELLYFIN_API_KEY=$(rbw get homepage-dashboard --field=jellyfin-api-key)
          HOMEPAGE_VAR_JELLYSEERR_API_KEY=$(rbw get homepage-dashboard --field=jellyseerr-api-key)
          HOMEPAGE_VAR_SONARR_API_KEY=$(rbw get homepage-dashboard --field=sonarr-api-key)
          HOMEPAGE_VAR_RADARR_API_KEY=$(rbw get homepage-dashboard --field=radarr-api-key)
          HOMEPAGE_VAR_PROWLARR_API_KEY=$(rbw get homepage-dashboard --field=prowlarr-api-key)
          HOMEPAGE_VAR_IMMICH_API_KEY=$(rbw get homepage-dashboard --field=immich-api-key)
          HOMEPAGE_VAR_TRUENAS_API_KEY=$(rbw get homepage-dashboard --field=truenas-api-key)
          "'';
        path = cfg.environmentFile;
        owner = "homepage-dashboard";
      };

    }
    (mkIf cfg.enableNginx {
      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          geo-ip = true;
        };
      };
      paul.dyndns = {
        enable = true;
        domains = [ cfg.domain ];
      };
      services.oauth2-proxy.nginx.virtualHosts."${cfg.domain}" = {
        allowed_groups = [ "homepage_users" ];
      };
    })

  ]);

}


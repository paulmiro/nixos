{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.homepage-dashboard;
in
{
  options.paul.homepage-dashboard = with lib; {
    enable = mkEnableOption "activate homepage";
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "allow homepage port in firewall";
    };
    enableNginx = mkEnableOption "activate nginx";
    domain = mkOption {
      type = types.str;
      default = config.paul.private.domains.homepage-dashboard;
      description = "domain for homepage";
    };
    port = mkOption {
      type = types.port;
      default = 8082;
      description = "port for homepage";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.homepage-dashboard = {
          enable = true;
          openFirewall = cfg.openFirewall;
          listenPort = cfg.port;
          environmentFile = config.clan.core.vars.generators.homepage-dashboard.files.env.path;
          allowedHosts = "localhost:8082,127.0.0.1:8082,${cfg.domain}";

          settings = {
            # todo use something like for a different image every time "https://source.unsplash.com/1920x1080/?nature,water";
            background = {
              image = "https://images.unsplash.com/photo-1651870364199-fc5f9f46ac85?w=1920";
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
              {
                Other = {
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
            /*
              # this requires a click on the widget to get the location permissions, wich is really annoying, maybe use private module to store my home location?
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
                  "File Browser" = [
                    {
                      abbr = "FB";
                      icon = "filebrowser.png";
                      href = "https://${config.paul.private.domains.filebrowser}";
                      description = "File Browser";
                    }
                  ];
                }
                {
                  "Speedtest" = [
                    {
                      abbr = "ST";
                      icon = "openspeedtest.png";
                      href = "https://${config.paul.private.domains.librespeedtest}";
                      description = "Speedtest";
                    }
                  ];
                }
                {
                  "TheLounge" = [
                    {
                      abbr = "TL";
                      icon = "thelounge.png";
                      href = "http://hawking:9337";
                      description = "IRC";
                    }
                  ];
                }
                {
                  "Uptime Kuma" = [
                    {
                      abbr = "UK";
                      icon = "uptime-kuma.png";
                      href = "https://morse:3001";
                      description = "Uptime Kuma";
                    }
                  ];
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
                      version = 2;
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
            {
              Other = [
                {
                  Authentik = {
                    icon = "authentik.png";
                    href = "https://${config.paul.authentik.domain}";
                    description = "Authentik";
                    widget = {
                      type = "authentik";
                      url = "https://${config.paul.authentik.domain}";
                      key = "{{HOMEPAGE_VAR_AUTHENTIK_API_TOKEN}}";
                    };
                  };
                }
              ];
            }
          ];
        };

        systemd.services.homepage-dashboard = {
          environment = {
            # TODO: test if this hack is still needed
            HOMEPAGE_CACHE_DIR = "/var/cache/homepage-dashboard";
          };
          serviceConfig = {
            CacheDirectory = "homepage-dashboard";
            user = "homepage-dashboard";
          };
        };

        clan.core.vars.generators.homepage-dashboard = {
          prompts.jellyfin-api-key.description = "Jellyfin API Key for Homepage Dashboard (see bw)";
          prompts.jellyfin-api-key.type = "hidden";
          prompts.jellyfin-api-key.persist = false;

          prompts.jellyseerr-api-key.description = "Jellyseerr API Key for Homepage Dashboard (see bw)";
          prompts.jellyseerr-api-key.type = "hidden";
          prompts.jellyseerr-api-key.persist = false;

          prompts.sonarr-api-key.description = "Sonarr API Key for Homepage Dashboard (see bw)";
          prompts.sonarr-api-key.type = "hidden";
          prompts.sonarr-api-key.persist = false;

          prompts.radarr-api-key.description = "Radarr API Key for Homepage Dashboard (see bw)";
          prompts.radarr-api-key.type = "hidden";
          prompts.radarr-api-key.persist = false;

          prompts.prowlarr-api-key.description = "Prowlarr API Key for Homepage Dashboard (see bw)";
          prompts.prowlarr-api-key.type = "hidden";
          prompts.prowlarr-api-key.persist = false;

          prompts.immich-api-key.description = "Immich API Key for Homepage Dashboard (see bw)";
          prompts.immich-api-key.type = "hidden";
          prompts.immich-api-key.persist = false;

          prompts.truenas-api-key.description = "TrueNas API Key for Homepage Dashboard (see bw)";
          prompts.truenas-api-key.type = "hidden";
          prompts.truenas-api-key.persist = false;

          prompts.authentik-api-token.description = "Authentik API Token for Homepage Dashboard (see bw)";
          prompts.authentik-api-token.type = "hidden";
          prompts.authentik-api-token.persist = false;

          files.env.secret = true;

          script = ''
            echo "
            HOMEPAGE_VAR_JELLYFIN_API_KEY=$(cat $prompts/jellyfin-api-key)
            HOMEPAGE_VAR_JELLYSEERR_API_KEY=$(cat $prompts/jellyseerr-api-key)
            HOMEPAGE_VAR_SONARR_API_KEY=$(cat $prompts/sonarr-api-key)
            HOMEPAGE_VAR_RADARR_API_KEY=$(cat $prompts/radarr-api-key)
            HOMEPAGE_VAR_PROWLARR_API_KEY=$(cat $prompts/prowlarr-api-key)
            HOMEPAGE_VAR_IMMICH_API_KEY=$(cat $prompts/immich-api-key)
            HOMEPAGE_VAR_TRUENAS_API_KEY=$(cat $prompts/truenas-api-key)
            HOMEPAGE_VAR_AUTHENTIK_API_TOKEN=$(cat $prompts/authentik-api-token)
            " > $out/env
          '';
        };
      }

      (lib.mkIf cfg.enableNginx {
        services.nginx.virtualHosts."${cfg.domain}" = {
          enableAuthentik = true;
          enableACME = true;
          forceSSL = true;
          enableDyndns = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            geo-ip = true;
          };
        };
      })
    ]
  );

}

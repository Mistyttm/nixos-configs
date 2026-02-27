{ config, lib, ... }:
{
  sops.secrets."sonarr_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."radarr_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."sabnzbd/api_key" = {
    sopsFile = ../../../secrets/sabnzbd.yaml;
  };

  sops.secrets."jellyfin_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."jellyseerr_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."prowlarr_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."bazarr_api_key" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.secrets."qbittorrent_password" = {
    sopsFile = ../../../secrets/media.yaml;
  };

  sops.templates."homepage-env" = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder."sonarr_api_key"}
      HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder."radarr_api_key"}
      HOMEPAGE_VAR_SABNZBD_API_KEY=${config.sops.placeholder."sabnzbd/api_key"}
      HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder."jellyfin_api_key"}
      HOMEPAGE_VAR_JELLYSEERR_API_KEY=${config.sops.placeholder."jellyseerr_api_key"}
      HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder."prowlarr_api_key"}
      HOMEPAGE_VAR_BAZARR_API_KEY=${config.sops.placeholder."bazarr_api_key"}
      HOMEPAGE_VAR_QBITTORRENT_PASSWORD=${config.sops.placeholder."qbittorrent_password"}
    '';
  };

  systemd.services.homepage-dashboard = {
    serviceConfig = {
      PrivateUsers = lib.mkForce false;
      SupplementaryGroups = [ "media" ];
    };
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = 3000;
    openFirewall = true;
    environmentFiles = [ config.sops.templates."homepage-env".path ];

    # Allow access from LAN and WireGuard
    allowedHosts = "192.168.0.171,10.100.0.2,localhost,127.0.0.1,thekennel";

    settings = {
      title = "The Kennel";
      favicon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homepage.png";
      theme = "dark";
      color = "slate";

      layout = {
        "Media" = {
          style = "row";
          columns = 3;
        };
        "Downloads" = {
          style = "row";
          columns = 3;
        };
        "Management" = {
          style = "row";
          columns = 3;
        };
      };
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      # {
      #   resources = {
      #     disk = "/mnt/media";
      #     label = "NAS Media";
      #   };
      # }
      {
        resources = {
          disk = "/mnt/localExpansion";
          label = "Local Expansion";
        };
      }
      {
        speedtest = {
          bitratePrecision = 0;
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        openmeteo = {
          label = "Brisbane";
          latitude = -27.47;
          longitude = 153.02;
          units = "metric";
          cache = 5;
        };
      }
    ];

    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              icon = "jellyfin";
              href = "http://192.168.0.171:8096";
              description = "Media server";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                enableBlocks = true;
              };
            };
          }
          {
            "Jellyseerr" = {
              icon = "jellyseerr";
              href = "http://192.168.0.171:5055";
              description = "Media requests";
              widget = {
                type = "jellyseerr";
                url = "http://127.0.0.1:5055";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
              };
            };
          }
          {
            "Tdarr" = {
              icon = "tdarr";
              href = "http://192.168.0.171:8265";
              description = "Media transcoding";
              widget = {
                type = "tdarr";
                url = "http://127.0.0.1:8265";
              };
            };
          }
        ];
      }
      {
        "Downloads" = [
          {
            "SABnzbd" = {
              icon = "sabnzbd";
              href = "http://192.168.0.171:8085";
              description = "Usenet downloader";
              widget = {
                type = "sabnzbd";
                url = "http://127.0.0.1:8085";
                key = "{{HOMEPAGE_VAR_SABNZBD_API_KEY}}";
              };
            };
          }
          {
            "qBittorrent" = {
              icon = "qbittorrent";
              href = "http://192.168.0.171:8080";
              description = "Torrent client";
              widget = {
                type = "qbittorrent";
                url = "http://127.0.0.1:8080";
                username = "admin";
                password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
              };
            };
          }
          {
            "Bazarr" = {
              icon = "bazarr";
              href = "http://192.168.0.171:6767";
              description = "Subtitle management";
              widget = {
                type = "bazarr";
                url = "http://127.0.0.1:6767";
                key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
              };
            };
          }
        ];
      }
      {
        "Management" = [
          {
            "Sonarr" = {
              icon = "sonarr";
              href = "http://192.168.0.171:8989";
              description = "TV series management";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:8989";
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
              };
            };
          }
          {
            "Radarr" = {
              icon = "radarr";
              href = "http://192.168.0.171:7878";
              description = "Movie management";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
              };
            };
          }
          {
            "Prowlarr" = {
              icon = "prowlarr";
              href = "http://192.168.0.171:9696";
              description = "Indexer management";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:9696";
                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
              };
            };
          }
        ];
      }
    ];

    bookmarks = [
      {
        "NixOS" = [
          {
            "NixOS Search" = [
              {
                abbr = "NS";
                href = "https://search.nixos.org/packages";
              }
            ];
          }
          {
            "NixOS Wiki" = [
              {
                abbr = "NW";
                href = "https://wiki.nixos.org/";
              }
            ];
          }
          {
            "Home Manager Options" = [
              {
                abbr = "HM";
                href = "https://home-manager-options.extranix.com/";
              }
            ];
          }
        ];
      }
      {
        "Arr Docs" = [
          {
            "Sonarr Wiki" = [
              {
                abbr = "SO";
                href = "https://wiki.servarr.com/sonarr";
              }
            ];
          }
          {
            "Radarr Wiki" = [
              {
                abbr = "RA";
                href = "https://wiki.servarr.com/radarr";
              }
            ];
          }
          {
            "TRaSH Guides" = [
              {
                abbr = "TG";
                href = "https://trash-guides.info/";
              }
            ];
          }
        ];
      }
    ];
  };
}

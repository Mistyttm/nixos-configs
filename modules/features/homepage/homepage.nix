{self, ...}: {
  flake.nixosModules.homepage = {
    pkgs,
    config,
    lib,
    ...
  }: let
    # RouterOS REST API on the hAP ax3, used by the Network tab.
    routerUrl = "http://192.168.0.1";
    routerAuth = {
      username = "{{HOMEPAGE_VAR_MIKROTIK_USERNAME}}";
      password = "{{HOMEPAGE_VAR_MIKROTIK_PASSWORD}}";
    };
    # customapi widget for GET ${routerUrl}/rest/<path>; `extra` adds mappings etc.
    routerApi = path: extra:
      {
        type = "customapi";
        url = "${routerUrl}/rest/${path}";
      }
      // routerAuth
      // extra;
    # RouterOS returns numbers as strings; scale = 1 coerces them for formatting.
    bits = field: label: {
      inherit field label;
      format = "bitrate";
      scale = 1;
    };
  in {
    sops.secrets."sonarr_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."radarr_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."sabnzbd/api_key" = {
      sopsFile = self.secrets.sabnzbd;
    };

    sops.secrets."jellyfin_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."jellyseerr_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."prowlarr_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."bazarr_api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."qbittorrent_password" = {
      sopsFile = self.secrets.media;
    };
    sops.secrets."dispatcharr/username" = {
      sopsFile = self.secrets.media;
    };
    sops.secrets."dispatcharr/password" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."jellystat/api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."cleanuparr/api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."wizarr/api_key" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."qnap/username" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."qnap/password" = {
      sopsFile = self.secrets.media;
    };

    sops.secrets."adguard_username" = {
      key = "username";
      sopsFile = self.secrets.adguard;
    };
    sops.secrets."adguard_password" = {
      key = "password";
      sopsFile = self.secrets.adguard;
    };

    sops.secrets."crowdsec_homepage_password" = {
      sopsFile = self.secrets.crowdsec;
    };

    # Read-only RouterOS user for the REST API (hAP ax3 at 192.168.0.1).
    sops.secrets."mikrotik_username" = {
      key = "username";
      sopsFile = self.secrets.mikrotik;
    };
    sops.secrets."mikrotik_password" = {
      key = "password";
      sopsFile = self.secrets.mikrotik;
    };

    sops.templates."homepage-env" = {
      owner = "root";
      group = "root";
      mode = "0400";
      restartUnits = ["homepage-dashboard.service"];
      content = ''
        HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder."sonarr_api_key"}
        HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder."radarr_api_key"}
        HOMEPAGE_VAR_SABNZBD_API_KEY=${config.sops.placeholder."sabnzbd/api_key"}
        HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder."jellyfin_api_key"}
        HOMEPAGE_VAR_JELLYSEERR_API_KEY=${config.sops.placeholder."jellyseerr_api_key"}
        HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder."prowlarr_api_key"}
        HOMEPAGE_VAR_BAZARR_API_KEY=${config.sops.placeholder."bazarr_api_key"}
        HOMEPAGE_VAR_QBITTORRENT_PASSWORD=${config.sops.placeholder."qbittorrent_password"}
        HOMEPAGE_VAR_DISPATCHARR_USERNAME=${config.sops.placeholder."dispatcharr/username"}
        HOMEPAGE_VAR_DISPATCHARR_PASSWORD=${config.sops.placeholder."dispatcharr/password"}
        HOMEPAGE_VAR_JELLYSTAT_API_KEY=${config.sops.placeholder."jellystat/api_key"}
        HOMEPAGE_VAR_CLEANUPARR_API_KEY=${config.sops.placeholder."cleanuparr/api_key"}
        HOMEPAGE_VAR_WIZARR_API_KEY=${config.sops.placeholder."wizarr/api_key"}
        HOMEPAGE_VAR_QNAP_USERNAME=${config.sops.placeholder."qnap/username"}
        HOMEPAGE_VAR_QNAP_PASSWORD=${config.sops.placeholder."qnap/password"}
        HOMEPAGE_VAR_ADGUARD_USERNAME=${config.sops.placeholder."adguard_username"}
        HOMEPAGE_VAR_ADGUARD_PASSWORD=${config.sops.placeholder."adguard_password"}
        HOMEPAGE_VAR_CROWDSEC_PASSWORD=${config.sops.placeholder."crowdsec_homepage_password"}
        HOMEPAGE_VAR_MIKROTIK_USERNAME=${config.sops.placeholder."mikrotik_username"}
        HOMEPAGE_VAR_MIKROTIK_PASSWORD=${config.sops.placeholder."mikrotik_password"}
      '';
    };

    # Serve the background image via nginx so it's accessible as a URL
    services.nginx.virtualHosts."homepage-lan".locations."/homepage_background.jpg" = {
      root = pkgs.runCommand "homepage-bg-dir" {} ''
        mkdir -p $out
        cp ${./homepage_background.jpg} $out/homepage_background.jpg
      '';
      extraConfig = ''
        expires 7d;
        add_header Cache-Control "public";
      '';
    };

    systemd.services.homepage-dashboard = {
      path = [pkgs.speedtest-cli];
      serviceConfig = {
        PrivateUsers = lib.mkForce false;
        SupplementaryGroups = ["media"];
      };
    };

    services.homepage-dashboard = {
      enable = true;
      package = pkgs.homepage-dashboard;

      listenPort = 3000;
      openFirewall = true;
      environmentFiles = [config.sops.templates."homepage-env".path];

      # Allow access from LAN and WireGuard
      allowedHosts = "192.168.0.171,10.100.0.2,localhost,127.0.0.1,thekennel";

      settings = {
        title = "The Kennel";
        favicon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homepage.png";
        theme = "dark";
        color = "slate";
        background = {
          image = "/homepage_background.jpg";
        };
        cardBlur = "xl";

        # A list (not an attrset) so Nix doesn't sort the groups: Homepage
        # orders groups and tabs by their position here. The Home groups keep
        # the alphabetical order the old attrset rendered in. Every group needs
        # a tab, otherwise Homepage shows it on all tabs.
        layout = [
          {
            "Downloads" = {
              tab = "Home";
              style = "row";
              columns = 3;
            };
          }
          {
            "Infrastructure" = {
              tab = "Home";
              style = "row";
              columns = 3;
            };
          }
          {
            "Management" = {
              tab = "Home";
              style = "row";
              columns = 3;
            };
          }
          {
            "Matrix" = {
              tab = "Home";
              style = "row";
              columns = 3;
            };
          }
          {
            "Media" = {
              tab = "Home";
              style = "row";
              columns = 4;
            };
          }
          {"NixOS" = {tab = "Home";};}
          {"Arr Docs" = {tab = "Home";};}
          {
            "Router" = {
              tab = "Network";
              style = "row";
              columns = 3;
            };
          }
          {
            "Traffic" = {
              tab = "Network";
              style = "row";
              columns = 3;
            };
          }
          {
            "Clients" = {
              tab = "Network";
              style = "row";
              columns = 2;
            };
          }
        ];
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
                href = "http://10.100.0.2:8096";
                description = "Media server";
                widget = {
                  type = "jellyfin";
                  url = "http://127.0.0.1:8096";
                  key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                  enableBlocks = true;
                  version = 2;
                  showEpisodeNumber = true;
                  enableUser = true;
                };
              };
            }
            {
              "Jellystat" = {
                icon = "jellystat";
                href = "http://10.100.0.2:3005";
                description = "Jellyfin statistics";
                widget = {
                  type = "jellystat";
                  url = "http://10.100.0.2:3005";
                  key = "{{HOMEPAGE_VAR_JELLYSTAT_API_KEY}}";
                  days = 30;
                };
              };
            }
            {
              "Seerr" = {
                icon = "seerr";
                href = "http://10.100.0.2:5055";
                description = "Media requests";
                widget = {
                  type = "seerr";
                  url = "http://127.0.0.1:5055";
                  key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                };
              };
            }
            {
              "Wizarr" = {
                icon = "wizarr";
                href = "https://wizarr.mistyttm.dev";
                description = "Media server invitations";
                widget = {
                  type = "customapi";
                  url = "http://127.0.0.1:5690/api/status";
                  method = "GET";
                  headers = {
                    "X-API-Key" = "{{HOMEPAGE_VAR_WIZARR_API_KEY}}";
                  };
                  mappings = [
                    {
                      field = "users";
                      label = "USERS";
                      format = "number";
                    }
                    {
                      field = "pending";
                      label = "PENDING INVITES";
                      format = "number";
                    }
                    {
                      field = "expired";
                      label = "EXPIRED INVITES";
                      format = "number";
                    }
                  ];
                };
              };
            }
            {
              "Tdarr" = {
                icon = "tdarr";
                href = "http://10.100.0.2:8265";
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
                href = "http://10.100.0.2:8085";
                description = "Usenet downloader";
                widget = {
                  type = "sabnzbd";
                  url = "http://127.0.0.1:8085";
                  key = "{{HOMEPAGE_VAR_SABNZBD_API_KEY}}";
                };
              };
            }
            # {
            #   "qBittorrent" = {
            #     icon = "qbittorrent";
            #     href = "http://10.100.0.2:8080";
            #     description = "Torrent client";
            #     widget = {
            #       type = "qbittorrent";
            #       # qbittorrent vpn loopback
            #       url = "http://127.0.0.1:8080";
            #       username = "admin";
            #       password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
            #     };
            #   };
            # }
            {
              "QUI" = {
                icon = "qbittorrent";
                href = "http://10.100.0.2:7476";
                description = "qBittorrent web UI";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "Seeding";
                      query = "sum(qbittorrent_torrents_seeding{job=\"thekennel\"})";
                      format = {type = "number";};
                    }
                    {
                      label = "Downloading";
                      query = "sum(qbittorrent_torrents_downloading{job=\"thekennel\"})";
                      format = {type = "number";};
                    }
                    {
                      label = "DL Speed";
                      query = "sum(rate(qbittorrent_session_download_bytes{job=\"thekennel\"}[5m]))";
                      format = {
                        type = "bytes";
                        suffix = "/s";
                      };
                    }
                    {
                      label = "UL Speed";
                      query = "sum(rate(qbittorrent_session_upload_bytes{job=\"thekennel\"}[5m]))";
                      format = {
                        type = "bytes";
                        suffix = "/s";
                      };
                    }
                  ];
                };
              };
            }
            {
              "Bazarr" = {
                icon = "bazarr";
                href = "http://10.100.0.2:6767";
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
                href = "http://10.100.0.2:8989";
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
                href = "http://10.100.0.2:7878";
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
                href = "http://10.100.0.2:9696";
                description = "Indexer management";
                widget = {
                  type = "prowlarr";
                  url = "http://127.0.0.1:9696";
                  key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                };
              };
            }
            {
              "Dispatcharr" = {
                icon = "dispatcharr";
                href = "http://10.100.0.2:9191";
                description = "IPTV stream management";
                widget = {
                  type = "dispatcharr";
                  url = "http://127.0.0.1:9191";
                  username = "{{HOMEPAGE_VAR_DISPATCHARR_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_DISPATCHARR_PASSWORD}}";
                  enableActiveStreams = true;
                };
              };
            }
            {
              "Cleanuparr" = {
                icon = "cleanuparr.png";
                href = "http://10.100.0.2:11011";
                description = "Media cleanup automation";
                widget = {
                  type = "customapi";
                  url = "http://127.0.0.1:11011/api/v2/stats";
                  refreshInterval = 10000;
                  method = "GET";
                  headers = {
                    "X-Api-Key" = "{{HOMEPAGE_VAR_CLEANUPARR_API_KEY}}";
                  };
                  mappings = [
                    {
                      field = "events.total";
                      label = "EVENTS (7D)";
                      format = "number";
                    }
                    {
                      field = "strikes.total";
                      label = "STRIKES";
                      format = "number";
                    }
                    {
                      field = "removals.total";
                      label = "REMOVED";
                      format = "number";
                    }
                    {
                      field = "cleaned.total";
                      label = "CLEANED";
                      format = "number";
                    }
                  ];
                };
              };
            }
            {
              "QNAP" = {
                icon = "qnap";
                href = "http://192.168.0.170:8080";
                description = "NAS storage";
                widget = {
                  type = "qnap";
                  url = "http://192.168.0.170:8080";
                  username = "{{HOMEPAGE_VAR_QNAP_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_QNAP_PASSWORD}}";
                };
              };
            }
          ];
        }
        {
          "Infrastructure" = [
            {
              "thedogpark" = {
                icon = "linux";
                href = "https://thedogpark";
                description = "Sydney VPS";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "CPU %";
                      query = "100 - (avg(rate(node_cpu_seconds_total{job=\"thedogpark\",mode=\"idle\"}[5m])) * 100)";
                      format = {
                        type = "number";
                        options = {maximumFractionDigits = 1;};
                      };
                    }
                    {
                      label = "Mem %";
                      query = "100 - (node_memory_MemAvailable_bytes{job=\"thedogpark\"} / node_memory_MemTotal_bytes{job=\"thedogpark\"} * 100)";
                      format = {
                        type = "number";
                        options = {maximumFractionDigits = 1;};
                      };
                    }
                  ];
                };
              };
            }
            {
              "thedogpark nginx" = {
                icon = "nginx";
                href = "https://thedogpark";
                description = "VPS reverse proxy";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "Active";
                      query = "nginx_connections_active{job=\"thedogpark\"}";
                      format = {type = "number";};
                    }
                    {
                      label = "Writing";
                      query = "nginx_connections_writing{job=\"thedogpark\"}";
                      format = {type = "number";};
                    }
                    {
                      label = "Waiting";
                      query = "nginx_connections_waiting{job=\"thedogpark\"}";
                      format = {type = "number";};
                    }
                  ];
                };
              };
            }
            {
              "thedogpark WireGuard" = {
                icon = "wireguard";
                href = "https://thedogpark";
                description = "VPS VPN";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "Peers";
                      query = "count(wireguard_sent_bytes_total{job=\"thedogpark\"})";
                      format = {type = "number";};
                    }
                    {
                      label = "Sent";
                      query = "sum(wireguard_sent_bytes_total{job=\"thedogpark\"})";
                      format = {type = "bytes";};
                    }
                    {
                      label = "Received";
                      query = "sum(wireguard_received_bytes_total{job=\"thedogpark\"})";
                      format = {type = "bytes";};
                    }
                  ];
                };
              };
            }
            {
              "thekennel" = {
                icon = "linux";
                href = "http://10.100.0.2";
                description = "Home server";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "CPU %";
                      query = "100 - (avg(rate(node_cpu_seconds_total{job=\"thekennel\",mode=\"idle\"}[5m])) * 100)";
                      format = {
                        type = "number";
                        options = {maximumFractionDigits = 1;};
                      };
                    }
                    {
                      label = "Mem %";
                      query = "100 - (node_memory_MemAvailable_bytes{job=\"thekennel\"} / node_memory_MemTotal_bytes{job=\"thekennel\"} * 100)";
                      format = {
                        type = "number";
                        options = {maximumFractionDigits = 1;};
                      };
                    }
                  ];
                };
              };
            }
            {
              "thekennel nginx" = {
                icon = "nginx";
                href = "http://10.100.0.2";
                description = "Home server reverse proxy";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "Active";
                      query = "nginx_connections_active{job=\"thekennel\"}";
                      format = {type = "number";};
                    }
                    {
                      label = "Writing";
                      query = "nginx_connections_writing{job=\"thekennel\"}";
                      format = {type = "number";};
                    }
                    {
                      label = "Waiting";
                      query = "nginx_connections_waiting{job=\"thekennel\"}";
                      format = {type = "number";};
                    }
                  ];
                };
              };
            }
            {
              "thekennel WireGuard" = {
                icon = "wireguard";
                href = "http://10.100.0.2";
                description = "Home server VPN";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "Peers";
                      query = "count(wireguard_sent_bytes_total{job=\"thekennel\"})";
                      format = {type = "number";};
                    }
                    {
                      label = "Sent";
                      query = "sum(wireguard_sent_bytes_total{job=\"thekennel\"})";
                      format = {type = "bytes";};
                    }
                    {
                      label = "Received";
                      query = "sum(wireguard_received_bytes_total{job=\"thekennel\"})";
                      format = {type = "bytes";};
                    }
                  ];
                };
              };
            }
            {
              "AdGuard Home" = {
                icon = "adguard-home";
                href = "http://10.100.0.6:3000";
                description = "Adguard Home on the foodbowl pi";
                widget = {
                  type = "adguard";
                  url = "http://10.100.0.6:3000";
                  username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                };
              };
            }
            {
              "thedogpark CrowdSec" = {
                icon = "crowdsec";
                href = "https://app.crowdsec.net";
                description = "VPS intrusion prevention";
                widget = {
                  type = "crowdsec";
                  url = "http://10.100.0.1:8180";
                  username = "homepage";
                  password = "{{HOMEPAGE_VAR_CROWDSEC_PASSWORD}}";
                };
              };
            }
          ];
        }
        {
          "Matrix" = [
            {
              "Synapse" = {
                icon = "matrix";
                href = "https://mistyttm.dev";
                description = "Matrix homeserver";
                widget = {
                  type = "prometheusmetric";
                  url = "http://localhost:9090";
                  metrics = [
                    {
                      label = "In-flight";
                      query = "sum(synapse_http_server_in_flight_requests_count{job=\"thedogpark\"})";
                      format = {type = "number";};
                    }
                    {
                      label = "Federation TX";
                      query = "rate(synapse_federation_client_sent_transactions_total{job=\"thedogpark\"}[5m])";
                      format = {
                        type = "number";
                        options = {maximumFractionDigits = 2;};
                        suffix = "/s";
                      };
                    }
                    {
                      label = "Events";
                      query = "synapse_storage_events_persisted_events_total{job=\"thedogpark\"}";
                      format = {type = "number";};
                    }
                  ];
                };
              };
            }
            {
              "mautrix-discord" = {
                icon = "discord";
                href = "https://mistyttm.dev";
                description = "Discord bridge";
              };
            }
            {
              "coturn" = {
                icon = "coturn";
                href = "https://mistyttm.dev";
                description = "TURN server";
              };
            }
          ];
        }
        {
          "Router" = [
            {
              "hAP ax3" = {
                icon = "mikrotik";
                href = routerUrl;
                description = "MikroTik router";
                widget =
                  {
                    type = "mikrotik";
                    url = routerUrl;
                  }
                  // routerAuth;
              };
            }
            {
              "WAN" = {
                icon = "mdi-wan";
                href = routerUrl;
                description = "ether1 (DHCP)";
                widget = routerApi "ip/dhcp-client" {
                  refreshInterval = 60000;
                  mappings = [
                    {
                      field = "0.address";
                      label = "Public IP";
                    }
                    {
                      field = "0.status";
                      label = "Status";
                    }
                    {
                      field = "0.expires-after";
                      label = "Lease left";
                    }
                  ];
                };
              };
            }
            {
              "Health" = {
                icon = "mdi-thermometer";
                href = routerUrl;
                description = "Router sensors";
                widget = routerApi "system/health" {
                  refreshInterval = 30000;
                  display = "dynamic-list";
                  mappings = {
                    name = "name";
                    label = "value";
                  };
                };
              };
            }
          ];
        }
        {
          "Traffic" = [
            {
              "WAN throughput" = {
                icon = "mdi-speedometer";
                href = routerUrl;
                description = "Live rate on ether1";
                widget = routerApi "interface/monitor-traffic" {
                  method = "POST";
                  headers = {"Content-Type" = "application/json";};
                  requestBody = {
                    interface = "ether1";
                    once = "";
                  };
                  refreshInterval = 5000;
                  mappings = [
                    (bits "0.rx-bits-per-second" "Download")
                    (bits "0.tx-bits-per-second" "Upload")
                  ];
                };
              };
            }
            {
              "SQM (CAKE)" = {
                icon = "mdi-tune-variant";
                href = routerUrl;
                description = "Simple queue wan-cake (down/up)";
                # Simple-queue stats are "down/up" strings that customapi can't split, so show them raw.
                widget = routerApi "queue/simple?name=wan-cake" {
                  refreshInterval = 5000;
                  mappings = [
                    {
                      field = "0.max-limit";
                      label = "Limit";
                    }
                    {
                      field = "0.dropped";
                      label = "Drops";
                    }
                    {
                      field = "0.queued-packets";
                      label = "Queued pkts";
                    }
                  ];
                };
              };
            }
            {
              "Connections" = {
                icon = "mdi-lan-connect";
                href = routerUrl;
                description = "Connection tracking";
                widget = routerApi "ip/firewall/connection/tracking" {
                  refreshInterval = 10000;
                  mappings = [
                    {
                      field = "total-entries";
                      label = "Active";
                      format = "number";
                    }
                    {
                      field = "max-entries";
                      label = "Max";
                      format = "number";
                    }
                  ];
                };
              };
            }
          ];
        }
        {
          "Clients" = [
            {
              "Wi-Fi" = {
                icon = "mdi-wifi";
                href = routerUrl;
                description = "Associated clients";
                widget = routerApi "interface/wifi/registration-table?.proplist=interface" {
                  mappings = [
                    {
                      label = "Clients";
                      format = "size";
                    }
                  ];
                };
              };
            }
            {
              "DHCP leases" = {
                icon = "mdi-devices";
                href = routerUrl;
                description = "Bound devices on the LAN";
                widget = routerApi "ip/dhcp-server/lease?status=bound&.proplist=host-name,address" {
                  refreshInterval = 30000;
                  display = "dynamic-list";
                  mappings = {
                    name = "host-name";
                    label = "address";
                    limit = 25;
                  };
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
  };
}

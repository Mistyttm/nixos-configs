{...}: {
  flake.nixosModules.qbittorrent = {...}: let
    downloadPath = "/mnt/localExpansion/qbittorrent/downloads";
    tempPath = "/mnt/localExpansion/qbittorrent/incomplete";
    torrentExportDir = "/mnt/localExpansion/qbittorrent/torrents";
  in {
    services.qbittorrent = {
      enable = true;
      openFirewall = true;

      # Use the native NixOS option for the port to ensure it applies
      webuiPort = 8080;

      serverConfig = {
        Application = {
          FileLogger = {
            Age = 1;
            AgeType = 1;
            Backup = true;
            DeleteOld = true;
            Enabled = true;
            MaxSizeBytes = 66560;
            Path = "logs";
          };
        };
        BitTorrent = {
          Session = {
            AddTorrentStopped = false;
            AlternativeGlobalDLSpeedLimit = 10240;
            AlternativeGlobalUPSpeedLimit = 10240;
            ExcludedFileNames = "";
            GlobalMaxRatio = 2;
            GlobalMaxSeedingMinutes = 15840;
            # Proton only forwards IPv4, so announce from IPv4 only ("All IPv4 addresses")
            InterfaceAddress = "0.0.0.0";
            MaxActiveDownloads = 10;
            MaxActiveTorrents = 20;
            MaxActiveUploads = 10;
            # Fixed local NAT-PMP port; qbittorrent-natpmp sets the live port to Proton's public one at runtime
            Port = 39065;
            QueueingSystemEnabled = false;
            SSL = {
              Port = 20173;
            };
            ShareLimitAction = "RemoveWithContent";
            StartPaused = false;
            Tags = "cross-seed";
            UseAlternativeGlobalSpeedLimit = true;
          };
        };
        Core = {
          AutoDeleteAddedTorrentFile = "Never";
        };
        Downloads = {
          SavePath = downloadPath;
          TempPath = tempPath;
          TempPathEnabled = true;
          TorrentExportDir = torrentExportDir;
          DefaultSavePath = downloadPath;
        };
        # Pinning this skips qBittorrent's startup migrations, so keys must use their current names
        Meta = {
          MigrationVersion = 12;
        };
        Network = {
          PortForwardingEnabled = false;
          Proxy = {
            HostnameLookupEnabled = false;
            Profiles = {
              BitTorrent = true;
              Misc = true;
              RSS = true;
            };
          };
        };
        Preferences = {
          Connection = {
            ResolvePeerCountries = true;
          };
        };
        RSS = {
          AutoDownloader = {
            DownloadRepacks = true;
            SmartEpisodeFilter = ''s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"'';
          };
        };
        WebUI = {
          AuthSubnetWhitelist = "@Invalid()";
          Enabled = true;
          Password_PBKDF2 = ''"@ByteArray(DiKrHs4S4j4pgnbP0+Vung==:eOcLXZTTGJqkayOBJJwaJM2dveNffFuRxcxsL57cliBfLtsHADg3xrd4w/HNy6TUSnBk1k2zJ3bof9dECXYHqg==)"'';
          Username = "admin";
        };
      };
    };

    systemd.services.qbittorrent.serviceConfig.UMask = "002";
  };
}

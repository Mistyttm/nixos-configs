{ ... }:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      Downloads = {
        SavePath = "/mnt/localExpansion/qbittorrent/downloads";
        TempPath = "/mnt/localExpansion/qbittorrent/incomplete";
        TempPathEnabled = true;
        TorrentExportDir = "/mnt/localExpansion/qbittorrent/torrents";
      };
      Preferences = {
        WebUI = {
          Enabled = true;
          Username = "admin";
          Password_PBKDF2 = ''"@ByteArray(DiKrHs4S4j4pgnbP0+Vung==:eOcLXZTTGJqkayOBJJwaJM2dveNffFuRxcxsL57cliBfLtsHADg3xrd4w/HNy6TUSnBk1k2zJ3bof9dECXYHqg==)"'';
          AuthSubnetWhitelist = "@Invalid()";
          Port = 8080;
        };
      };
    };
  };
}

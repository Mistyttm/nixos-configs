{ ... }:
let
  downloadPath = "/mnt/localExpansion/qbittorrent/downloads";
  tempPath = "/mnt/localExpansion/qbittorrent/incomplete";
  torrentExportDir = "/mnt/localExpansion/qbittorrent/torrents";
in
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      Downloads = {
        SavePath = downloadPath;
        TempPath = tempPath;
        TempPathEnabled = true;
        TorrentExportDir = torrentExportDir;
      };
      Preferences = {
        WebUI = {
          Enabled = true;
          Username = "admin";
          Password_PBKDF2 = ''"@ByteArray(DiKrHs4S4j4pgnbP0+Vung==:eOcLXZTTGJqkayOBJJwaJM2dveNffFuRxcxsL57cliBfLtsHADg3xrd4w/HNy6TUSnBk1k2zJ3bof9dECXYHqg==)"'';
          AuthSubnetWhitelist = "@Invalid()";
          Port = 8081;
        };
      };
    };
  };

  # Fix: Force qBittorrent to use NixOS serverConfig on every start
  # by removing the runtime config file so it regenerates from our settings
  systemd.services.qbittorrent.preStart = ''
    CONFIG_FILE="/var/lib/qBittorrent/qBittorrent.conf"
    if [ -f "$CONFIG_FILE" ]; then
      rm -f "$CONFIG_FILE"
    fi
  '';
}

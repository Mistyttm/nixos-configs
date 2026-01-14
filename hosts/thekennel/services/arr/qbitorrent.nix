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

    # Use the native NixOS option for the port to ensure it applies
    webuiPort = 8080;

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
        };
      };
    };
  };

  # Manually open the port as `openFirewall` might default to the `torrentingPort` or standard 8080
  networking.firewall.allowedTCPPorts = [ 8081 ];
}

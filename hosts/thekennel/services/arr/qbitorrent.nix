{ pkgs, ... }:
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
          Port = 8080;
        };
      };
    };
  };

  # Fix: Ensure download paths are enforced on each service start
  # qBittorrent stores its runtime config in /var/lib/qBittorrent and ignores
  # the NixOS serverConfig after first run. This ensures paths are always correct.
  systemd.services.qbittorrent.preStart = ''
    CONFIG_FILE="/var/lib/qBittorrent/qBittorrent.conf"
    if [ -f "$CONFIG_FILE" ]; then
      ${pkgs.gnused}/bin/sed -i \
        -e 's|^Downloads\\SavePath=.*|Downloads\\SavePath=${downloadPath}|' \
        -e 's|^Downloads\\TempPath=.*|Downloads\\TempPath=${tempPath}|' \
        -e 's|^Downloads\\TorrentExportDir=.*|Downloads\\TorrentExportDir=${torrentExportDir}|' \
        "$CONFIG_FILE"
    fi
  '';
}

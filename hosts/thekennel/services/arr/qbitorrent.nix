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
    };
  };
}

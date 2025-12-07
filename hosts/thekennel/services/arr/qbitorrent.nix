{ ... }:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      # Set default save path
      "Downloads/SavePath" = "/mnt/localExpansion/qbittorrent/downloads";

      # Set temp path for incomplete downloads
      "Downloads/TempPath" = "/mnt/localExpansion/qbittorrent/incomplete";
      "Downloads/TempPathEnabled" = true;

      # Optional: Set path for .torrent files
      "Downloads/TorrentExportDir" = "/mnt/localExpansion/qbittorrent/torrents";
    };
  };
}

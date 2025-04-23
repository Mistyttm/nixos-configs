{ pkgs, config, ... }: 
{
  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
    mediaDirs = [ "/mnt/media" ];
  };

  # Enable Remote Storage
  fileSystems."/mnt/media" = {
    device = "//192.168.0.170/Public/Media";
    fsType = "nfs";
    options = [
      "rw"
      "hard"
      "intr"
      "nfsvers=4"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/media 0755 jellyfin jellyfin -"
  ];
}
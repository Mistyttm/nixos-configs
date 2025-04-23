{ pkgs, config, ... }: 
{
  sops.secrets."nas-username" = {
    sopsFile = ../../secrets/samba.yaml;
    owner = "root";
  };
  sops.secrets."nas-password" = {
    sopsFile = ../../secrets/samba.yaml;
    owner = "root";
  };

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
  # fileSystems."/mnt/media" = {
  #   device = "//192.168.0.170/Public/Media";
  #   fsType = "nfs";
  #   options = [
  #     "credentials=/run/media-credentials" 
  #     "uid=1000"
  #     "gid=100" 
  #     "iocharset=utf8"
  #     "vers=3.0"
  #     "x-systemd.automount"
  #     "noauto"
  #   ];
  # };
}
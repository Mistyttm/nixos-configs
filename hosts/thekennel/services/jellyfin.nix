{ pkgs, config, ... }: 
{
  sops.secrets."samba-key" = {
    sopsFile = ../../secrets/samba.yaml;
    owner = config.users.users.jellyfin.name;
    group = config.users.users.jellyfin.group;
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
  fileSystems."/mnt/media" = {
    device = "//192.168.0.170/Public/Media";
    fsType = "cifs";
    options = [ "username=eddie" "passwordfile=${config.sops.secrets."samba-key".path}" "x-systemd.automount" "noauto" ];
  };
}
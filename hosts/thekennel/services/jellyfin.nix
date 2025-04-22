{ pkgs, config, ... }: 
{
  sops.secrets."nas-username" = {
    sopsFile = ../../secrets/samba.yaml;
    owner = config.users.users.jellyfin.name;
    group = config.users.users.jellyfin.group;
  };
  sops.secrets."nas-password" = {
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
    options = [
      "username=${builtins.readFile config.sops.secrets."nas-username".path}"
      "passwordfile=${builtins.readFile config.sops.secrets."nas-password".path}" 
      "uid=1000"
      "gid=100" 
      "iocharset=utf8"
      "vers=3.0"
    ];
  };
}
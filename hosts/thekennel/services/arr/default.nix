{ config, ... }:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
    ./mullvad.nix
    ./prowlarr.nix
    ./qbitorrent.nix
    ./flaresolverr.nix
    ./jellyseer.nix
    ./sabnzbd.nix
    ./bazarr.nix
  ];

  sops.secrets."qnap-media/username" = {
    sopsFile = ../../../../secrets/qnap.yaml;
  };

  sops.secrets."qnap-media/password" = {
    sopsFile = ../../../../secrets/qnap.yaml;
  };

  sops.templates.qnap-media-cifs = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      username=${config.sops.placeholder."qnap-media/username"}
      password=${config.sops.placeholder."qnap-media/password"}
    '';
  };

  users.groups.media = { };

  users.users.jellyfin.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sabnzbd.extraGroups = [ "media" ];
  users.users.bazarr.extraGroups = [ "media" ];
}

{ pkgs, ... }:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
    ./mullvad.nix
    ./prowlarr.nix
    ./qbitorrent.nix
    ./flaresolverr.nix
    ./jellyseer.nix
  ];

  sops.secrets.qnap-media = {
    owner = "root";
    group = "root";
    mode = "0400";
    format = "yaml";
  };

  system.activationScripts.qnapMediaCreds.text = ''
    install -m 0400 /dev/null /run/secrets/qnap-media.cifs
    echo "username=$(yq -r .username /run/secrets/qnap-media)" >> /run/secrets/qnap-media.cifs
    echo "password=$(yq -r .password /run/secrets/qnap-media)" >> /run/secrets/qnap-media.cifs
  '';

  users.groups.media = { };

  users.users.jellyfin.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.radarr.extraGroups = [ "media" ];
}

{
  config,
  pkgs,
  lib,
  ...
}:
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
    ./tdarr.nix
    ./fail2ban.nix
    ./recyclarr.nix
    ./docker.nix
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

  environment.systemPackages = with pkgs; [
    btop # Resource monitor
    ncdu # Disk usage analyzer
    mediainfo # Media file inspector
    mkvtoolnix # MKV manipulation tools
    bc
  ];

  users.groups.media = {
    gid = 986;
  };

  users.users.sponsor = {
    isNormalUser = true;
    home = "/var/lib/sponsor-block";
    description = "Sponsor Block";
    extraGroups = [ "media" ];
  };

  users.users.jellyfin.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sabnzbd.extraGroups = [ "media" ];
  users.users.bazarr.extraGroups = [ "media" ];
  # users.users.tdarr.extraGroups = [ "media" ];

  systemd.services.isponsorblocktv = {
    description = "isponsorblocktv background service";
    after = [
      "network.target"
      "multi-user.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.isponsorblocktv}";
      Restart = "on-failure";
      RestartSec = 10;
      User = "sponsor";
      StandardOutput = "journal";
    };
  };
}

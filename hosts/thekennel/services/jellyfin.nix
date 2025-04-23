{ pkgs, config, ... }: 
{
  # sops.secrets."nas-username" = {
  #   sopsFile = ../../secrets/smb-creds.yaml;
  #   owner = "root";
  # };
  # sops.secrets."nas-password" = {
  #   sopsFile = ../../secrets/smb-creds.yaml;
  #   owner = "root";
  # };

  # # Systemd service to generate /run/media-credentials at runtime
  # systemd.services."generate-media-creds" = {
  #   wantedBy = [ "local-fs.target" ];
  #   before = [ "mnt-media.mount" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "gen-creds" ''
  #       install -m 600 -o root -g root /dev/null /run/media-credentials
  #       echo "username=$(cat ${config.sops.secrets."nas-username".path})" > /run/media-credentials
  #       echo "password=$(cat ${config.sops.secrets."nas-password".path})" >> /run/media-credentials
  #     '';
  #   };
  # };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
  };
}
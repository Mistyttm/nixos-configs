{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    (jellyfin-ffmpeg.override {
      ffmpeg-headless = ffmpeg-headless.override { withCuda = true; };
    })
  ];

  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
  };
}

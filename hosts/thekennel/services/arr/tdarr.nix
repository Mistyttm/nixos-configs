{ pkgs, ... }:

{
  services.tdarr = {
    enable = false;
    openFirewall = true; # Opens ports 8265 (web UI) and 8266 (API)
    # enableCCExtractor = true;
    cronPluginUpdate = "";
    extraServerConfig = {
      ffmpegPath = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
      ffprobePath = "${pkgs.jellyfin-ffmpeg}/bin/ffprobe";
      handbrakePath = "${pkgs.handbrake}/bin/HandBrakeCLI";
      mkvpropeditPath = "${pkgs.mkvtoolnix}/bin/mkvpropedit";
    };
    nodes.gpu = {
      enable = true;
      workers = {
        transcodeGPU = 1; # Use 1 GPU worker (adjust as needed)
        transcodeCPU = 1; # Optional: also use 1 CPU worker
        healthcheckGPU = 1; # Optional: GPU healthcheck
        healthcheckCPU = 1;
      };
    };
    group = "media";
  };
}

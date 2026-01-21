{ ... }:

{
  services.tdarr = {
    enable = true;
    openFirewall = true; # Opens ports 8265 (web UI) and 8266 (API)
    enableCCExtractor = true;
    cronPluginUpdate = true;
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

{...}: {
  flake.nixosModules.ollama = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      package = pkgs.ollama-cuda;
      loadModels = [
        "qwen3-coder:30b"
      ];
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "30m";
        OLLAMA_MAX_LOADED_MODELS = "1";

        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_CONTEXT_LENGTH = "32768";
      };
    };
  };
}

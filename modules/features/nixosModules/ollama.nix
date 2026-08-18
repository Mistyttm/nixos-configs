{...}: {
  flake.nixosModules.ollama = {...}: {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      loadModels = [
        "qwen3:14b"
        "qwen3.5:27b"
        "qwen3-coder:30b"
        "qwen3.6:27b"
      ];
    };
  };
}

{...}: {
  flake.nixosModules.ollama = {...}: {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      loadModels = [
        "qwen3:14b"
        "kimi-k2.6"
      ];
    };
  };
}

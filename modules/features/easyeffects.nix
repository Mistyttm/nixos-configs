{...}: {
  flake.homeModules.easyeffects = {...}: {
    services.easyeffects = {
      enable = true;

      preset.input = "mic";

      # Mic chain. Only non-default values are listed; EasyEffects fills the
      # rest of each plugin from its defaults when the preset is loaded.
      extraPresets.mic.input = {
        blocklist = [];
        plugins_order = [
          "rnnoise#0"
          "compressor#0"
          "stereo_tools#0"
          "deepfilternet#0"
        ];
        "rnnoise#0" = {
          bypass = false;
          enable-vad = true;
        };
        "compressor#0".bypass = false;
        "stereo_tools#0" = {
          bypass = false;
          mode = "LR > LL (Mono Left Channel)";
        };
        "deepfilternet#0" = {
          bypass = false;
          post-filter-beta = 0.02;
        };
      };

      settings.Window = {
        xdgGlobalShortcuts = true;
      };
    };
  };
}

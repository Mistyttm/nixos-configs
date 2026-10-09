{...}: {
  flake.nixosModules.wivrn = {pkgs, ...}: {
    services.wivrn = {
      enable = true;
      package = pkgs.wivrn.override {
        cudaSupport = true;
      };
      openFirewall = true;
      autoStart = true;
      config = {
        enable = true;
        json = {
          scale = 1.0;
          bitrate = 50000000;
          encoders = [
            {
              encoder = "nvenc";
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
          application = [pkgs.wayvr];
        };
      };
    };
  };
}

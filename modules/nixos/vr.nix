{ config, lib, pkgs, ...}: let cfg = config.gaming.vr; in {
  options.gaming.vr = {
    enable = lib.mkEnableOption "Enable VR for this system";
    wivrn = {
      enable = lib.mkEnableOption "Enable wivrn";
      package = lib.mkOption {
        type = pkgs.lib.types.package;
        default = pkgs.wivrn;
        example = pkgs.wivrn;
        description = ''
          The package to use for wivrn
        '';
      };
      encoder = lib.mkOption {
        type = lib.types.str;
        default = "nvenc";
        example = "nvenc";
        description = ''
          The encoder to use for wivrn
        '';
      };
      overlay = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        example = lib.literalEpression "[ pkgs.wlx-overlay-s ]";
        description = ''
          List of overlays to add to the system for wivrn
        '';
      };
    };
    # enableSidequest = lib.mkEnableOption "Enable Sidequest";
  };

  config = lib.mkIf cfg.enable {
    services.wivrn = {
      enable = cfg.wivrn.enable;
      package = (cfg.wivrn.package.overrideAttrs (old:  {
        cmakeFlags = old.cmakeFlags ++ [
          (lib.cmakeFeature "OPENCOMPOSITE_SEARCH_PATH" "${pkgs.opencomposite}/lib/opencomposite")
        ];
      }));
      openFirewall = true;
      defaultRuntime = true;
      autoStart = true;
      config = {
        enable = true;
        json = {
          scale = 1.0;
          bitrate = 50000000;
          encoders = [
            {
              encoder = cfg.wivrn.encoder;
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
          application = cfg.wivrn.overlay;
        };
      };
    };
    environment.systemPackages = cfg.wivrn.overlay ++ [
      pkgs.opencomposite
      pkgs.monado-vulkan-layers
    ];
  };
}

{ lib, options, config, pkgs, ... }: with lib; let cfg = config.gaming; in {
  imports = [
    ./vr.nix # Import the VR module
  ];

  options.gaming = {
    enable = mkEnableOption "Enable gaming for this system";

    user = mkOption {
      type = pkgs.lib.types.str;
      default = "misty";
      example = "yourUsername";
      description = ''
        The username of the user for whom Home Manager should configure gaming options.
      '';
    };

    steam = {
      enable = mkEnableOption "Enable Steam";
      portable = mkOption {
        type = pkgs.lib.types.bool;
        default = false;
        example = true;
        description = ''
          Enable specific options for steam on laptop
        '';
      };
    };

    minecraft = {
      enable = mkEnableOption "Enable Minecraft via PrismLauncher";
      jdkOverrides = mkOption {
        type = pkgs.lib.types.listOf pkgs.lib.types.package;
        default = [];
        example = [ pkgs.jdk8 pkgs.jdk17 pkgs.jdk21 ];
        description = ''
          List of JDKs to use for PrismLauncher
        '';
      };
    };

    dolphin = mkEnableOption "Enable Dolphin Emulator";
    lutris = mkEnableOption "Enable Lutris";
    gamemode = mkEnableOption "Enable GameMode";
    cloneHero = mkEnableOption "Enable Clone Hero";
    YARG = mkEnableOption "Enable YARG";
  };
  config = mkIf cfg.enable {
    # NixOS options
    programs.steam = {
      enable = cfg.steam.enable;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [
          gamescope
          mangohud
      ];
      package = pkgs.steam.override {
        extraEnv = if cfg.steam.portable then {
          __NV_PRIME_RENDER_OFFLOAD = 1;
          __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        } else {
          OBS_VKCAPTURE = true;
        };
#         extraLibraries = p: with p; [
#           mono
#           mono4
#           mono5
#         ];
      };
    };

    programs.gamemode = {
      enable = cfg.gamemode;
    };

    # Home Manager options
    home-manager.users.${cfg.user} = {
      home.packages = with pkgs; [
        (mkIf cfg.minecraft.enable (prismlauncher.override {
          jdks = cfg.minecraft.jdkOverrides;
        }))
        (mkIf cfg.steam.enable pkgs.protonup-qt)
        (mkIf cfg.dolphin pkgs.dolphin-emu-beta)
        (mkIf cfg.lutris pkgs.lutris)
        (mkIf cfg.cloneHero pkgs.clonehero)
        (mkIf cfg.YARG pkgs.yarg)
      ];

      programs.mangohud = {
        enable = cfg.gamemode;
      };
    };
  };
}

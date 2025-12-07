{ ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "misty";
      desktopSession = "plasma";
      environment = {
        # Disable hardware cursors - this is critical for Nvidia
        WLR_NO_HARDWARE_CURSORS = "1";
        KWIN_FORCE_SW_CURSOR = "1";

        # Nvidia-specific fixes
        __GL_GSYNC_ALLOWED = "0";
        __GL_VRR_ALLOWED = "0";
        __GL_SYNC_TO_VBLANK = "1";

        # Color space fix for yellow tint
        GAMESCOPE_COLOR_SPACE = "sRGB";

        # SDL controller settings
        SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
        SDL_JOYSTICK_HIDAPI = "1";
      };
    };
    decky-loader = {
      enable = true;

    };
    steamos = {
      enableBluetoothConfig = true;
      enableDefaultCmdlineConfig = true;
      enableEarlyOOM = true;
      enableProductSerialAccess = true;
      enableSysctlConfig = true;
      enableZram = true;
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
}

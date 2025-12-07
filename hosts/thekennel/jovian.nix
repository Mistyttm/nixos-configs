{ ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "misty";
      desktopSession = "plasma";
      environment = {
        # Disable VRR/G-Sync which can cause flickering
        __GL_GSYNC_ALLOWED = "0";
        __GL_VRR_ALLOWED = "0";

        # Fix hardware cursor issues (often the main culprit)
        WLR_NO_HARDWARE_CURSORS = "1";

        # Additional stability options
        __GL_YIELD = "USLEEP";
        ENABLE_VKBASALT = "0";
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
}

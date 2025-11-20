{ ... }: {
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "misty";
      desktopSession = "gamescope-wayland";
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

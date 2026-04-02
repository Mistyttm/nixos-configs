{ ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "misty";
      desktopSession = "plasma";
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

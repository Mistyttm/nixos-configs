{
  config,
  lib,
  pkgs,
  ...
}:
{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };
  boot.kernelParams = [ "amd_pstate=guided" ];
}

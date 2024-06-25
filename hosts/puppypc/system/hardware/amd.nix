{ config, lib, pkgs, ... }: {
  powerManagement = {
    cpuFreqGovernor = "schedutil";
  };
  boot.kernelParams = [ "amd_pstate=guided" ];
}

{ ... }:
{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };
  boot.kernelParams = [ "amd_pstate=guided" ];
  hardware.cpu.amd = {
    updateMicrocode = true;
    
  };
}

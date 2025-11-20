{ ... }:
{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };
  boot.kernelParams = [
    "amd_pstate=active"  # Changed from 'guided' for better stability under load
    "processor.max_cstate=1"  # Limit deep sleep states to prevent instability
    # Additional stability for PBO + EXPO RAM overclocking:
    "amd_pstate.max_perf_pct=90"  # Limit max CPU frequency to 90% - reduces voltage/heat
    "mem_sleep_default=shallow"  # Prevent deep memory power states
  ];
  hardware.cpu.amd = {
    updateMicrocode = true;

  };
}

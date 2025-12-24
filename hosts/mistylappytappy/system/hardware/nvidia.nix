{ ... }:
{
  hardware.nvidia-custom = {
    enable = true;
    driverChannel = "latest";
    prime = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}

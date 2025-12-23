{ config, pkgs, ... }:
{
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    monado-vulkan-layers
    nvidia-vaapi-driver
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # Blacklist the new Nova/NovaCore driver (kernel 6.18+) which conflicts
  # with the proprietary NVIDIA driver. The module name is nova_core.
  boot.blacklistedKernelModules = [
    "nova"
    "novacore"
    "nova_core"
    "nouveau" # Also blacklist nouveau just in case
  ];

  # Disable nova_core via kernel command line (needed if built into kernel)
  boot.kernelParams = [
    "module_blacklist=nova_core,nova,novacore"
  ];

  hardware.nvidia = {

    modesetting.enable = true;

    powerManagement.enable = false;

    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}

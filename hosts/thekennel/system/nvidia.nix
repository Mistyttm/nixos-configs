{ config, pkgs, ... }:
{
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    monado-vulkan-layers
    intel-vaapi-driver
  ];

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    forceFullCompositionPipeline = true;
  };
}

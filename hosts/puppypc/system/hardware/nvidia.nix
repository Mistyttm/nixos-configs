{ config, pkgs, ... }:
{
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    monado-vulkan-layers
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    modesetting.enable = true;

    powerManagement.enable = false;

    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}

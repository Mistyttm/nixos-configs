{ pkgs, ... }:
{
  hardware.nvidia-custom = {
    enable = true;
    driverChannel = "beta";
    forceFullCompositionPipeline = true;
    extraGraphicsPackages = with pkgs; [
      intel-vaapi-driver
    ];
    nvidiaContainerToolkit = true;
  };
}

{ pkgs, ... }:
{
  hardware.nvidia-custom = {
    enable = true;
    driverChannel = "beta";
    blacklistNova = true;
    extraGraphicsPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
}

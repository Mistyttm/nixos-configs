{ config, lib, pkgs, ... }: {
  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "/dev/nvme1n1p1";
    };
  };
}

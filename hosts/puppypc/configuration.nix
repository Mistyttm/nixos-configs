{ pkgs, ... }:

{
  imports =
    [
      ./system/default.nix
      ../../global-configs/system/default.nix
      ../../global-configs/users/default.nix
      ../../global-configs/fonts/fonts.nix
      ./configs/programs/VR/default.nix
      ../../global-configs/system/nixoptions.nix
    ];

  networking.hostName = "puppypc";

  boot.supportedFilesystems = [ "ntfs" ];

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  virtualisation.waydroid.enable = true;

  virtualisation.virtualbox = {
    host.enable = true;
    guest ={
      enable = true;
      clipboard = true;
      dragAndDrop = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      opencomposite
      monado-vulkan-layers
    ];
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    };
  };

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "freeimage-unstable-2021-11-01"
      ];
      cudaSupport = true;
    };
  };

  system.stateVersion = "unstable";

}

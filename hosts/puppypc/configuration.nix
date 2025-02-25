{ pkgs, ... }:

{
  imports =
    [
      ./system/default.nix
      ../../global-configs/system/default.nix
      ../../global-configs/users/default.nix
      ../../global-configs/fonts/fonts.nix
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

  gaming = {
    enable = true;
    user = "misty";
    vr = {
      enable = true;
      wivrn = {
        enable = true;
        package = pkgs.wivrn;
        encoder = "nvenc";
#         overlay = [ pkgs.wlx-overlay-s ];
      };
    };
    steam = {
      enable = true;
    };
    minecraft = {
      enable = true;
      jdkOverrides = with pkgs; [ jdk8 jdk17 jdk21 ];
    };
    dolphin = true;
    lutris = true;
    gamemode = true;
  };

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

  programs.adb.enable = true;

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "freeimage-unstable-2021-11-01"
      ];
      cudaSupport = true;
    };
  };

  system.stateVersion = "25.05";

}

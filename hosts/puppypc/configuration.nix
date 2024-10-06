# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./system/default.nix
      ../../global-configs/system/default.nix
      ../../global-configs/users/default.nix
      ../../global-configs/fonts/fonts.nix
    ];

  networking.hostName = "puppypc"; # Define your hostname.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

#   services.

  boot.supportedFilesystems = [ "ntfs" ];

#   services.

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  programs.alvr = {
    enable = true;
    package = pkgs.unstable.alvr;
    openFirewall = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  environment = {
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
                "freeimage-unstable-2021-11-01"
              ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

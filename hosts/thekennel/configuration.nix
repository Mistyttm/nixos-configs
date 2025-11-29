{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./jovian.nix
    ../../global-configs/users/misty.nix
    ../../global-configs/system/locale.nix
    ../../global-configs/system/networking/ssh.nix
    ../../global-configs/system/nixoptions.nix
    ../../global-configs/system/virtualisation.nix
    # ./services/jellyfin.nix
    ./system/nvidia.nix
    # ./services/arr/default.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "cifs" ];

  networking.hostName = "thekennel"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # CUDA support removed globally - now enabled per-package to avoid mass rebuilds
  # nixpkgs.config.cudaSupport = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  programs.nix-ld.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    zip
    unzip
    nano
    tmux
    sops
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # services.logind = {
  #   settings = {
  #     Login = {
  #       HandleLidSwitchExternalPower = "ignore";
  #       HandleLidSwitch = "ignore";
  #     };
  #   };
  # };

  system.stateVersion = "25.11";

}

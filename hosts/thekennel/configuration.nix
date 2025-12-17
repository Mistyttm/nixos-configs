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
    ../../global-configs/system/DE/kde.nix
    ../../global-configs/system/DE/audio.nix
    ./services/jellyfin.nix
    ./system/nvidia.nix
    ./services/arr/default.nix
    ./services/wireguard.nix
    ./services/nginx.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    consoleLogLevel = 0;

    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 10;
        enable = true;
      };

      timeout = 5;
    };

    plymouth.enable = true;
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

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

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    dnsovertls = "true";
  };

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;

  nixpkgs.config.cudaSupport = true;

  system.stateVersion = "26.05";

}

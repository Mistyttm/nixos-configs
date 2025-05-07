{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../global-configs/users/misty.nix
      ../../global-configs/system/locale.nix
      ../../global-configs/system/networking/ssh.nix
      ../../global-configs/system/nixoptions.nix
      ./services.nix
      ./minecraft.nix
      ./nginx.nix
      ./mailserver.nix
      ./matrix-synapse.nix
      ../../global-configs/system/virtualisation.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "thedogpark"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # sops.defaultSopsFile = ./secrets/porkbun.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";


  programs.nix-ld.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zip
    unzip
    nano
    tmux
    sops
    jdk21
    cron
    nix-ld
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };


  nixpkgs.config = {
    permittedInsecurePackages = [
      "olm-3.2.16"
    ];
    allowUnfree = true;
  };


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5173 24464 8448 443 3478 5349 ];
  networking.firewall.allowedUDPPorts = [ 5173 24464 3478 5349 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 2456; to = 2458; }
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 2456; to = 2458; }
    { from = 49152; to = 65535; }
  ];
  

  users.users.misty = {
    extraGroups = [ "minecraft" ];
  };

  system.stateVersion = "25.05"; # Did you read the comment?

}


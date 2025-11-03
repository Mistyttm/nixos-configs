{ inputs, pkgs, ... }:


{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../global-configs/users/misty.nix
    ../../global-configs/users/steam.nix
    ../../global-configs/system/locale.nix
    ../../global-configs/system/networking/ssh.nix
    ../../global-configs/system/nixoptions.nix
    # Services moved to microvms
    # ./services/default.nix
    # ./matrix/default.nix
    ../../global-configs/system/virtualisation.nix
    # MicroVM declarations
    ./microvms/default.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
      };
    };
  };

  networking.hostName = "thedogpark"; # Define your hostname.
  networking.networkmanager.enable = true;

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  programs.nix-ld.enable = true;

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

  # Open ports in the firewall - most services now run in MicroVMs
  # Port forwarding is handled in microvms/default.nix
  networking.firewall.allowedTCPPorts = [
    5173   # Development
    24464  # Additional service
  ];
  networking.firewall.allowedUDPPorts = [
    5173
    24464
  ];

  users.users.misty = {
    extraGroups = [ "minecraft" ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--print-build-logs"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}

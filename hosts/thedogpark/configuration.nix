{ inputs, pkgs, ... }:


{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../global-configs/users/misty.nix
    ../../global-configs/system/locale.nix
    ../../global-configs/system/networking/ssh.nix
    ../../global-configs/system/nixoptions.nix
    ./services/default.nix
    ./matrix/default.nix
    ../../global-configs/system/virtualisation.nix
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
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

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
  networking.firewall.allowedTCPPorts = [
    5173
    24464
    8448
    443
    3478
    5349
    25565
  ];
  networking.firewall.allowedUDPPorts = [
    5173
    24464
    3478
    5349
    25565
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 2456;
      to = 2458;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 2456;
      to = 2458;
    }
    {
      from = 49152;
      to = 65535;
    }
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

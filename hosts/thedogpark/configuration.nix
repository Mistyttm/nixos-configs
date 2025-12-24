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
    ../../global-configs/system/gnupg.nix
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
    9005
    7777
    8888
  ];
  networking.firewall.allowedUDPPorts = [
    5173
    24464
    3478
    5349
    25565
    7777
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

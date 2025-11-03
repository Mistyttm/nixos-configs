{ config, pkgs, ... }:
{
  # Basic microvm configuration for Minecraft server
  microvm = {
    hypervisor = "qemu";

    # Share host's nix store
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];

    # Network interface
    interfaces = [
      {
        type = "tap";
        id = "vm-minecraft";
        mac = "02:00:00:01:01:02";
      }
    ];

    # Memory allocation
    mem = 6144; # Reduced from 8GB to 6GB for Minecraft

    # CPU cores
    vcpu = 2; # Reduced from 4 to 2

    # Storage for Minecraft worlds
    volumes = [
      {
        image = "/var/lib/microvms/minecraft/worlds.img";
        mountPoint = "/var/lib/minecraft";
        size = 20480; # Reduced from 50GB to 20GB
      }
    ];
  };

  # Import existing Minecraft configuration
  imports = [
    ../services/minecraft.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  networking = {
    hostName = "minecraft-vm";
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        25565 # Minecraft
      ];
      allowedUDPPorts = [
        25565
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks."10-microvm" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "no";
        Address = "10.0.0.3/24";
        Gateway = "10.0.0.1";
        DNS = "10.0.0.1";
      };
    };
  };

  # Basic services
  services.resolved.enable = true;

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    nano
    tmux
    htop
    jdk21
  ];
}

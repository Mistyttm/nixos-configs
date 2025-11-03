{ pkgs, ... }:
{
  # Basic microvm configuration for gaming servers
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
      # Share Valheim server data
      {
        source = "/srv/valheim";
        mountPoint = "/srv/valheim";
        tag = "valheim";
        proto = "virtiofs";
      }
    ];

    # Network interface
    interfaces = [
      {
        type = "tap";
        id = "vm-gaming";
        mac = "02:00:00:01:01:04";
      }
    ];

    # Memory allocation (gaming servers need more)
    mem = 8192; # 8GB - enough for either Satisfactory or Valheim

    # CPU cores
    vcpu = 2; # Reduced from 4 to 2

    # Storage for game servers
    volumes = [
      {
        image = "/var/lib/microvms/gaming/steamuser.img";
        mountPoint = "/var/lib/steamuser";
        size = 30720; # Reduced from 100GB to 30GB
      }
    ];
  };

  # Basic system configuration
  system.stateVersion = "25.11";

  networking = {
    hostName = "gaming-vm";
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        7777 # Satisfactory
        8888 # Satisfactory query
      ];
      allowedUDPPorts = [
        7777 # Satisfactory
      ];
      allowedTCPPortRanges = [
        {
          from = 2456;
          to = 2458;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 2456;
          to = 2458;
        }
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks."10-microvm" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "no";
        Address = "10.0.0.5/24";
        Gateway = "10.0.0.1";
        DNS = "10.0.0.1";
      };
    };
  };

  # Basic services
  services.resolved.enable = true;

  # Enable Docker for Valheim
  virtualisation.docker.enable = true;

  # Valheim server service (disabled by default)
  systemd.services.valheimserver = {
    description = "Valheim Server";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];

    path = with pkgs; [
      docker
      tmux
    ];

    serviceConfig = {
      User = "root";
      Group = "root";
      WorkingDirectory = "/srv/valheim";
      ExecStart = "/srv/valheim/start.sh";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t valheimserver";
      Restart = "on-failure";
      RestartSec = "15s";
    };

    # Don't auto-start - start manually when needed
    # wantedBy = [ "multi-user.target" ];
  };

  # Satisfactory server service (enabled by default for now)
  systemd.services.satisfactory-server = {
    description = "Satisfactory Dedicated Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ]; # Auto-start this one

    serviceConfig = {
      Type = "simple";
      User = "steam";
      Group = "steam";
      WorkingDirectory = "/var/lib/steamuser/SatisfactoryDedicatedServer";
      ExecStart = "/var/lib/steamuser/SatisfactoryDedicatedServer/FactoryServer.sh";
      Restart = "on-failure";
      RestartSec = "10s";

      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/steamuser" ];

      # Resource limits
      LimitNOFILE = 65536;

      # Environment
      Environment = [
        "HOME=/var/lib/steamuser"
        "USER=steam"
      ];
    };
  };

  # Steam user
  users.users.steam = {
    isSystemUser = true;
    group = "steam";
    home = "/var/lib/steamuser";
    createHome = true;
  };
  users.groups.steam = { };

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    nano
    tmux
    htop
    docker
  ];
}

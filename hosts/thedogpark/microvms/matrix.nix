{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Basic microvm configuration for Matrix services
  microvm = {
    hypervisor = "qemu";

    # Share host's nix store to prevent huge images
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
      # Share secrets directory for sops
      {
        source = "/var/lib/microvms/matrix/secrets";
        mountPoint = "/var/lib/sops-nix";
        tag = "secrets";
        proto = "virtiofs";
      }
      # Share ACME certificates for Coturn
      {
        source = "/var/lib/acme";
        mountPoint = "/var/lib/acme";
        tag = "acme";
        proto = "virtiofs";
        readOnly = true;
      }
    ];

    # Network interface
    interfaces = [
      {
        type = "tap";
        id = "vm-matrix";
        mac = "02:00:00:01:01:01";
      }
    ];

    # Allocate memory
    mem = 2048; # Reduced from 4GB to 2GB

    # CPU cores
    vcpu = 2; # Reduced from 4 to 2

    # Storage for postgres and synapse data
    volumes = [
      {
        image = "/var/lib/microvms/matrix/postgres.img";
        mountPoint = "/var/lib/postgresql";
        size = 10240; # Reduced from 20GB to 10GB
      }
      {
        image = "/var/lib/microvms/matrix/synapse.img";
        mountPoint = "/var/lib/matrix-synapse";
        size = 5120; # Reduced from 10GB to 5GB
      }
    ];
  };

  # Import existing matrix configurations
  imports = [
    ../matrix/matrix-synapse.nix
    ../matrix/coturn.nix
    ../matrix/mautrix-discord.nix
    # ../matrix/mjolnir.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  networking = {
    hostName = "matrix-vm";
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8008 # Synapse
        9005 # Mautrix-Discord
        3478 # Coturn
        5349 # Coturn TLS
      ];
      allowedUDPPorts = [
        3478 # Coturn
        5349 # Coturn TLS
      ];
      allowedUDPPortRanges = [
        {
          from = 49152;
          to = 65535;
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
        Address = "10.0.0.2/24";
        Gateway = "10.0.0.1";
        DNS = "10.0.0.1";
      };
    };
  };

  # Basic services
  services.resolved.enable = true;

  # Users needed for services
  users.users.matrix-synapse = {
    isSystemUser = true;
    group = "matrix-synapse";
  };
  users.groups.matrix-synapse = { };

  users.users.turnserver = {
    isSystemUser = true;
    group = "turnserver";
  };
  users.groups.turnserver = { };

  users.users.mautrix-discord = {
    isSystemUser = true;
    group = "mautrix-discord";
  };
  users.groups.mautrix-discord = { };

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    nano
    tmux
    htop
  ];

  # SOPS configuration
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}

{ pkgs, ... }:
{
  # Basic microvm configuration for web services
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
      # Share secrets directory for sops (ACME credentials)
      {
        source = "/var/lib/microvms/web/secrets";
        mountPoint = "/var/lib/sops-nix";
        tag = "secrets";
        proto = "virtiofs";
      }
      # Share the personal website directory
      {
        source = "/home/misty/Documents/mistyttmpersonalsite";
        mountPoint = "/srv/mistyttmpersonalsite";
        tag = "website";
        proto = "virtiofs";
      }
    ];

    # Network interface
    interfaces = [
      {
        type = "tap";
        id = "vm-web";
        mac = "02:00:00:01:01:03";
      }
    ];

    # Memory allocation
    mem = 1024; # Reduced from 2GB to 1GB

    # CPU cores
    vcpu = 1; # Reduced from 2 to 1

    # Storage for nginx/ACME state
    volumes = [
      {
        image = "/var/lib/microvms/web/acme.img";
        mountPoint = "/var/lib/acme";
        size = 1024; # 1GB
      }
      {
        image = "/var/lib/microvms/web/nginx.img";
        mountPoint = "/var/lib/nginx";
        size = 1024; # 1GB
      }
    ];
  };

  # Import existing nginx configuration
  imports = [
    ../services/nginx.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  networking = {
    hostName = "web-vm";
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        8448 # Matrix federation
        8080 # Personal site
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks."10-microvm" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "no";
        Address = "10.0.0.4/24";
        Gateway = "10.0.0.1";
        DNS = "10.0.0.1";
      };
    };
  };

  # Basic services
  services.resolved.enable = true;

  # Personal website service (from services.nix)
  systemd.services.mistyttmpersonalsite = {
    description = "Build and run Vite for the MistyTTM Personal Site in production mode";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'cd /srv/mistyttmpersonalsite && ${pkgs.nodejs}/bin/npx vite --mode production --port 8080'";
      WorkingDirectory = "/srv/mistyttmpersonalsite";
      Restart = "on-failure";
      User = "nginx";
      Group = "nginx";
      Environment = "PATH=${pkgs.nodejs}/bin:${pkgs.nodejs}/lib/node_modules/.bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    };
  };

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    nano
    tmux
    htop
    nodejs
  ];

  # SOPS configuration
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}

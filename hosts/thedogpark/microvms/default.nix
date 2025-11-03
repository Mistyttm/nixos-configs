{ self, ... }:
{
  # Declarative MicroVMs configuration
  microvm.vms = {
    # Matrix services VM (Synapse, Mautrix-Discord, Coturn)
    matrix = {
      # Reference to the flake for updates
      flake = self;
      # Allow imperative updates
      updateFlake = "git+file:///etc/nixos";

      # Import the matrix microvm configuration
      config = import ./matrix.nix;
    };

    # Minecraft server VM
    minecraft = {
      flake = self;
      updateFlake = "git+file:///etc/nixos";

      config = import ./minecraft.nix;
    };

    # Web services VM (nginx, personal site, ACME)
    web = {
      flake = self;
      updateFlake = "git+file:///etc/nixos";

      config = import ./web.nix;
    };

    # Gaming servers VM (Valheim, Satisfactory)
    gaming = {
      flake = self;
      updateFlake = "git+file:///etc/nixos";

      config = import ./gaming.nix;
    };
  };

  # Automatically start these MicroVMs on boot
  # Gaming VM is excluded - start manually as needed
  microvm.autostart = [
    "matrix"
    "web"
    # "minecraft"  # Uncomment to auto-start
    # "gaming"     # Start manually: sudo systemctl start microvm@gaming
  ];

  # Host networking configuration for MicroVMs
  networking = {
    # Enable NAT for MicroVM network
    nat = {
      enable = true;
      internalInterfaces = [ "microvm" ];
      externalInterface = "ens3"; # Adjust this to your actual network interface
    };

    # Create bridge for MicroVMs
    bridges.microvm.interfaces = [ ];

    # Configure bridge interface
    interfaces.microvm = {
      ipv4.addresses = [
        {
          address = "10.0.0.1";
          prefixLength = 24;
        }
      ];
    };

    # Firewall rules for MicroVM network
    firewall = {
      trustedInterfaces = [ "microvm" ];

      # Forward ports from host to VMs
      extraCommands = ''
        # Forward HTTP/HTTPS to web VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.4:80
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.4:443
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 8448 -j DNAT --to-destination 10.0.0.4:8448

        # Forward Matrix Synapse to matrix VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 8008 -j DNAT --to-destination 10.0.0.2:8008

        # Forward TURN/STUN to matrix VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 3478 -j DNAT --to-destination 10.0.0.2:3478
        iptables -t nat -A PREROUTING -i ens3 -p udp --dport 3478 -j DNAT --to-destination 10.0.0.2:3478
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 5349 -j DNAT --to-destination 10.0.0.2:5349
        iptables -t nat -A PREROUTING -i ens3 -p udp --dport 5349 -j DNAT --to-destination 10.0.0.2:5349

        # Forward Minecraft to minecraft VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 25565 -j DNAT --to-destination 10.0.0.3:25565
        iptables -t nat -A PREROUTING -i ens3 -p udp --dport 25565 -j DNAT --to-destination 10.0.0.3:25565

        # Forward Satisfactory to gaming VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 7777 -j DNAT --to-destination 10.0.0.5:7777
        iptables -t nat -A PREROUTING -i ens3 -p udp --dport 7777 -j DNAT --to-destination 10.0.0.5:7777
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 8888 -j DNAT --to-destination 10.0.0.5:8888

        # Forward Valheim port range to gaming VM
        iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 2456:2458 -j DNAT --to-destination 10.0.0.5
        iptables -t nat -A PREROUTING -i ens3 -p udp --dport 2456:2458 -j DNAT --to-destination 10.0.0.5

        # Allow forwarding
        iptables -A FORWARD -i ens3 -o microvm -j ACCEPT
        iptables -A FORWARD -i microvm -o ens3 -j ACCEPT
      '';
    };
  };

  # Ensure /var/lib/microvms exists with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/microvms 0755 root root -"
    "d /var/lib/microvms/matrix 0755 root root -"
    "d /var/lib/microvms/matrix/secrets 0755 root root -"
    "d /var/lib/microvms/minecraft 0755 root root -"
    "d /var/lib/microvms/web 0755 root root -"
    "d /var/lib/microvms/web/secrets 0755 root root -"
    "d /var/lib/microvms/gaming 0755 root root -"
  ];
}

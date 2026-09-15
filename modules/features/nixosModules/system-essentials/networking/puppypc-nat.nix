{...}: {
  flake.nixosModules.puppypc-nat = {...}: {
    networking.networkmanager.ensureProfiles.profiles = {
      "enp12s0-shared" = {
        connection = {
          id = "enp12s0-shared";
          type = "ethernet";
          interface-name = "enp12s0";
        };
        ipv4 = {
          method = "manual";
          address1 = "192.168.50.1/24";
          "route1" = "192.168.0.0/24,192.168.50.251";
        };
        ipv6.method = "disabled";
      };
    };

    networking.nat = {
      enable = true;
      internalInterfaces = ["enp12s0"];
      externalInterface = "wlp13s0";
    };

    networking.firewall.trustedInterfaces = ["enp12s0"];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
}

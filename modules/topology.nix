{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      topology.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.nix-topology.overlays.default ];
      };

      topology.modules = [
        (
          { config, ... }:
          let
            inherit (config.lib.topology) mkConnection mkInternet mkRouter;
          in
          {
            config = {
              nodes.puppypc = {
                name = "Puppy PC";
                deviceType = "nixos";
                hardware.info = "Desktop on Wi-Fi";
                interfaces.wifi = {
                  type = "wifi";
                  network = "home-lan";
                };
              };

              nodes.puppylaptop = {
                name = "Puppy Laptop";
                deviceType = "nixos";
                hardware.info = "Laptop on Wi-Fi";
                interfaces.wifi = {
                  type = "wifi";
                  network = "home-lan";
                };
              };

              nodes.thekennel = {
                name = "The Kennel";
                deviceType = "nixos";
                hardware.info = "Desktop on Ethernet";
                interfaces.ethernet = {
                  type = "ethernet";
                  network = "home-lan";
                };
              };

              nodes.thedogpark = {
                name = "The Dog Park";
                deviceType = "nixos";
                hardware.info = "Remote VPS instance";
                interfaces.wan.type = "ethernet";
                interfaces.wan.network = "wan-net";
              };

              nodes.internet = mkInternet {
                connections = [
                  (mkConnection "router" "wan")
                  (mkConnection "thedogpark" "wan")
                ];
              };

              nodes.router = mkRouter "Home Router" {
                info = "Single router and Wi-Fi access point";
                interfaceGroups = [
                  [
                    "lan"
                    "wifi"
                  ]
                  [ "wan" ]
                ];
                connections.wifi = [
                  (mkConnection "puppypc" "wifi")
                  (mkConnection "puppylaptop" "wifi")
                ];
                connections.lan = mkConnection "thekennel" "ethernet";
                interfaces.lan.network = "home-lan";
                interfaces.wifi.network = "home-lan";
              };

              networks.home-lan = {
                name = "Home LAN";
                cidrv4 = "192.168.0.0/24";
              };
              networks.wan-net = {
                name = "WAN/Internet";
                cidrv4 = "0.0.0.0/0";
              };
            };
          }
        )
      ];
    };
}

{self, ...}: {
  flake.nixosModules.foodbowlConfiguration = {pkgs, ...}: {
    imports = with self.nixosModules; [
      foodbowlHardware
      foodbowlHomeManager
      adguardhome
      node-exporter
      system-essentials
      misty
      cli-tools
      nix-ld
      log-shipper
    ];

    networking.hostName = "foodbowl";

    boot.zfs.forceImportRoot = false;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # The SD card is too small for logs: keep the journal in RAM only.
    services.journald.settings.Journal = {
      Storage = "volatile";
      RuntimeMaxUse = "50M";
    };

    doggate = {
      adguardhome = {
        adminPasswordHash = "$2y$10$gDYaIJi.m/WFFhBi6GeVh.YcpPx6QRSX3f6lAeZQOkEnZr7o9LQoC%";
      };
      wireguard.enable = true;
      logShipping.files = [
        {
          path = "/var/lib/AdGuardHome/data/querylog.json";
          job = "adguard-querylog";
        }
      ];
    };

    # SSH on boot, password login.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    system.stateVersion = "26.11";
  };
}

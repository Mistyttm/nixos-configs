{self, ...}: let
  # Stage 2: set to true once `foodbowl_key` is in secrets/wireguard.yaml and
  # foodbowl's age key is a recipient of that file. Brings up WireGuard and
  # ships logs to thekennel.
  online = false;
in {
  flake.nixosModules.foodbowlConfiguration = {lib, ...}: {
    imports = with self.nixosModules;
      [
        foodbowlHardware
        foodbowlHomeManager
        adguardhome
        node-exporter
        system-essentials
        misty
        cli-tools
        nix-ld
      ]
      ++ lib.optional online self.nixosModules.foodbowlOnline;

    networking.hostName = "foodbowl";

    boot.zfs.forceImportRoot = false;

    # The SD card is too small for logs: keep the journal in RAM only.
    services.journald.settings.Journal = {
      Storage = "volatile";
      RuntimeMaxUse = "50M";
    };

    # AdGuard Home's web UI is localhost-only (ssh -L 3000:localhost:3000) until
    # a bcrypt hash is set, e.g.:
    # doggate.adguardhome.adminPasswordHash = "$2y$10$...";

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

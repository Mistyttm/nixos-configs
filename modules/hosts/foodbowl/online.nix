{
  self,
  inputs,
  ...
}: {
  # Everything foodbowl needs once it can decrypt secrets and reach wg0:
  # WireGuard, and shipping logs to Loki on thekennel. Enabled by flipping
  # `online` in configuration.nix.
  flake.nixosModules.foodbowlOnline = {...}: {
    imports = [
      # Not self.nixosModules.sops: that pins age.keyFile, but foodbowl decrypts
      # with its SSH host key (sops-nix default).
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.wireguard
      self.nixosModules.log-shipper
    ];

    doggate.wireguard.enable = true;

    doggate.logShipping.files = [
      {
        path = "/var/lib/AdGuardHome/data/querylog.json";
        job = "adguard-querylog";
      }
    ];
  };
}

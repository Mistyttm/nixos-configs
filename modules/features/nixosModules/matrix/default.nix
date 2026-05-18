{ self, ... }:
{
  flake.nixosModules.matrix =
    { ... }:
    {
      imports = [
        self.nixosModules.matrix-synapse
        self.nixosModules.mautrix-discord
        self.nixosModules.coturn
      ];
    };
}

{self, ...}: {
  flake.nixosModules.matrix = {...}: {
    imports = [
      self.nixosModules.matrix-synapse
      self.nixosModules.mautrix-discord
      self.nixosModules.coturn
    ];
    sops.secrets."shared_secret_auth_config" = {
      sopsFile = self.secrets.synapse;
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
  };
}

{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.system-essentials = {...}: {
    imports = [
      inputs.omniflake.flakes.nix-topology.nixosModules.default

      self.nixosModules.bootloader
      self.nixosModules.gnupg
      self.nixosModules.locale
      self.nixosModules.nix-ld
      self.nixosModules.nixoptions
      self.nixosModules.services
      self.nixosModules.sops
      self.nixosModules.systemd
      self.nixosModules.xdg
      self.nixosModules.fwupd

      self.nixosModules.networkmanager
      self.nixosModules.resolvd
      self.nixosModules.ssh
      self.nixosModules.wireguard
      self.nixosModules.nginx
    ];
  };
}

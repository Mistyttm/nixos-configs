{ self, inputs, ... }:
{
  flake.nixosModules.system-essentials =
    { ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops

        self.nixosModules.audio
        self.nixosModules.bootloader
        self.nixosModules.fonts
        self.nixosModules.gnupg
        self.nixosModules.locale
        self.nixosModules.nix-ld
        self.nixosModules.nixoptions
        self.nixosModules.services
        self.nixosModules.sops
        self.nixosModules.systemd
        self.nixosModules.xdg
        self.nixosModules.zram

        self.nixosModules.networkmanager
        self.nixosModules.resolvd
        self.nixosModules.ssh
        self.nixosModules.wireguard
        self.nixosModules.nginx
      ];
    };
}

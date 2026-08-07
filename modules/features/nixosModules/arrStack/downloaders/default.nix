{self, ...}: {
  flake.nixosModules.downloaders = {
    imports = [
      self.nixosModules.qbittorrent
      self.nixosModules.sabnzbd
      self.nixosModules.qui
    ];
  };
}

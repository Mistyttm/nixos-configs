{ self, inputs, ... }:
{
  flake.nixosModules.downloaders = {
    imports = [
      self.nixosModules.qbittorrent
      self.nixosModules.sabnzbd
    ];
  };
}

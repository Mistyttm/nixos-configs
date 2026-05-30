{ self, ... }:
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.sunshine
      ];

      environment.systemPackages = with pkgs; [
        dolphin-emu
      ];
    };
}

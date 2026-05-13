{ inputs, self, ... }:
{
  flake.nixosModules.gaming =
    { pkgs, lib, ... }:
    {

      environment.systemPackages = with pkgs; [
        dolphin-emu
      ];
    };
}

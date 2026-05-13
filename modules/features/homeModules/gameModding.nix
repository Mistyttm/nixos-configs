{ inputs, ... }:
{
  flake.homeModules.gameModding =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        blockbench
        bs-manager
        satisfactorymodmanager
        r2modman
        deadlock-mod-manager
      ];
    };
}

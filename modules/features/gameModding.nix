{...}: {
  flake-file.inputs.grimoire = {
    url = "github:Slush97/grimoire";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.homeModules.gameModding = {pkgs, ...}: {
    home.packages = with pkgs; [
      blockbench
      bs-manager
      satisfactorymodmanager
      r2modman
      grimoire
    ];
  };
}

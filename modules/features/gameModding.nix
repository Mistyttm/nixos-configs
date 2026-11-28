{...}: {
  flake-file.inputs.grimoire = {
    url = "github:Slush97/grimoire";
    group = "desktop";
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

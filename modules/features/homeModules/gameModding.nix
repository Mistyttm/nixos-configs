{ inputs, ... }:
{
  flake.homeModules.gameModding =
    { pkgs, ... }:
    {
      home.packages =
        with pkgs;
        [
          blockbench
          bs-manager
          satisfactorymodmanager
          r2modman
        ]
        ++ [
          inputs.deadlock-mod-manager.packages.${pkgs.system}.nightly
        ];
    };
}

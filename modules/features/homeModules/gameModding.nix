{inputs, ...}: {
  flake-file.inputs.deadlock-mod-manager = {
    url = "github:deadlock-mod-manager/deadlock-mod-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.homeModules.gameModding = {pkgs, ...}: {
    home.packages = with pkgs;
      [
        blockbench
        bs-manager
        satisfactorymodmanager
        r2modman
      ]
      ++ [
        (inputs.deadlock-mod-manager.packages.${pkgs.stdenv.hostPlatform.system}.nightly.overrideAttrs
          (_finalAttrs: oldAttrs: {
            checkFlags = oldAttrs.checkFlags or [] ++ ["--skip=mod_manager::steam_manager::tests::set_steam_dir_rejects_invalid_directory"];
          }))
      ];
  };
}

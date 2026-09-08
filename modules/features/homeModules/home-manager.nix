{inputs, ...}: {
  flake.nixosModules.homeManager = {...}: {
    imports = [
      inputs.omniflake.flakes.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      sharedModules = [
        inputs.omniflake.flakes.sops-nix.homeManagerModules.sops
        {home.stateVersion = "26.11";}
      ];
    };
  };
}

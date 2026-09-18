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
        {home.stateVersion = "26.11";}
      ];
    };
  };
}

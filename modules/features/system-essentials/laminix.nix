{inputs, ...}: {
  flake.nixosModules.laminix = {...}: {
    imports = [
      inputs.omniflake.flakes.laminix.nixosModules.default
    ];

    environment.laminix = {
      enable = true;
      plasma = "full";
      packages = [
        "kdePackages.kdeconnect-kde"
        "obs-studio"
      ];
    };
  };
}

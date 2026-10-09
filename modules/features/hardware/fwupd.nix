{...}: {
  flake.nixosModules.fwupd = {...}: {
    services.fwupd = {
      enable = true;
    };
  };
}

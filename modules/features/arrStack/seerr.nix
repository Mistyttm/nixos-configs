{...}: {
  flake.nixosModules.seerr = {...}: {
    services.seerr = {
      enable = true;
      openFirewall = true;
    };
  };
}

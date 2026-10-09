{...}: {
  flake.nixosModules.flaresolverr = {...}: {
    services.flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };
}

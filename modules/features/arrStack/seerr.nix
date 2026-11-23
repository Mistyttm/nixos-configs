{...}: {
  flake.nixosModules.seerr = {...}: {
    lantian.harden.seerr = {
      enable = true;
      bindPaths = ["/mnt/media"];
    };
    services.seerr = {
      enable = true;
      openFirewall = true;
    };
  };
}

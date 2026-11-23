{...}: {
  flake.nixosModules.seerr = {...}: {
    lantian.harden.seerr = {
      enable = false;
      bindPaths = ["/mnt/media"];
    };
    services.seerr = {
      enable = true;
      openFirewall = true;
    };
  };
}

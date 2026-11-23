{...}: {
  flake.nixosModules.seerr = {...}: {
    lantian.harden.seerr = {
      enable = "jit";
      enableConfinement = false;
      bindPaths = ["/mnt/media"];
    };
    services.seerr = {
      enable = true;
      openFirewall = true;
    };
  };
}

{...}: {
  flake.nixosModules.prowlarr = {pkgs, ...}: {
    lantian.harden.prowlarr = {
      enable = "jit";
      enableConfinement = false;
      bindPaths = ["/mnt/localExpansion"];
    };
    services.prowlarr = {
      enable = true;
      package = pkgs.prowlarr;
      openFirewall = true;
      dataDir = "/var/lib/prowlarr";
      settings = {
        update = {
          automatically = true;
        };
      };
    };
  };
}

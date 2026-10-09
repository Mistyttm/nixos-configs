{...}: {
  flake.nixosModules.lact = {pkgs, ...}: {
    services.lact = {
      enable = true;
      package = pkgs.lact;
    };
  };
}

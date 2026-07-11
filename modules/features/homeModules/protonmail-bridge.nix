{...}: {
  flake.homeModules.protonmail = {pkgs, ...}: {
    services.protonmail-bridge = {
      enable = true;
      package = pkgs.protonmail-bridge;
    };
  };
}

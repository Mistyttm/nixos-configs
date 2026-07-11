{...}: {
  flake.homeModules.protonmail = {pkgs, ...}: {
    home.packages = with pkgs; [
      protonmail-bridge-gui
    ];
    services.protonmail-bridge = {
      enable = true;
      package = pkgs.protonmail-bridge;
    };
  };
}

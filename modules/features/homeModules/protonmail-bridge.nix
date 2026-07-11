{...}: {
  flake.homeModules.protonmail = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      protonmail-bridge-gui
    ];
    programs.protonmail-bridge = {
      enable = true;
      package = pkgs.protonmail-bridge;
    };
  };
}

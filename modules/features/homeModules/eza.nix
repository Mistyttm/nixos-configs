{ inputs, ... }:
{
  flake.homeModules.eza =
    { pkgs, lib, ... }:
    {
      programs.eza = {
        enable = true;
        colors = "auto";
        enableZshIntegration = true;
        git = true;
        icons = "auto";
      };

      home.shellAliases = {
        ls = "eza -la";
      };
    };
}

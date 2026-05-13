{ inputs, ... }:
{
  flake.homeModules.ripgrep =
    { pkgs, lib, ... }:
    {
      programs.ripgrep = {
        enable = true;
      };

      home.shellAliases = {
        grep = "rg";
      };
    };
}

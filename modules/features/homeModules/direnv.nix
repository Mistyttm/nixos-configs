{ inputs, ... }:
{
  flake.homeModules.direnv =
    { pkgs, lib, ... }:
    {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };
    };
}

{
  self,
  inputs,
  config,
  ...
}:
{
  flake.homeModules.starship =
    { pkgs, ... }:
    {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}

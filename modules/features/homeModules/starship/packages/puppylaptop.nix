{
  inputs,
  palettes,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.puppylaptopStarship = inputs.wrapper-modules.wrappers.starship.wrap {
        inherit pkgs;
        package = pkgs.starship;
        settings = {
          palettes = palettes;
        };
      };
    };
}

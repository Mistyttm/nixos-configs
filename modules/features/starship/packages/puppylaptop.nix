{
  inputs,
  palettes,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.puppylaptopStarship = inputs.nix-wrapper-modules.wrappers.starship.wrap {
      inherit pkgs;
      package = pkgs.starship;
      settings = {
        palettes = palettes;
      };
    };
  };
}

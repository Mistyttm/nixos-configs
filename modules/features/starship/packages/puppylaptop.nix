{
  inputs,
  palettes,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.puppylaptopStarship = inputs.omniflake.flakes."github:nix-community/nix-wrapper-modules".wrappers.starship.wrap {
      inherit pkgs;
      package = pkgs.starship;
      settings = {
        palettes = palettes;
      };
    };
  };
}

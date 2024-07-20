{ pkgs, lib, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in
{

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];

  imports = [ spicetify-nix.homeManagerModule ];

  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.Dribbblish;
      colorScheme = "purple";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        seekSong
        fullAlbumDate
        adblock
        volumePercentage
      ];

      enabledCustomApps = with spicePkgs.apps; [
        marketplace
      ];
    };
}

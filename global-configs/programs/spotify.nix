{ pkgs, lib, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in
{

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];

  imports = [ spicetify-nix.homeManagerModules.default ];

  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.nightlight;
#       colorScheme = "purple";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplayMod
        seekSong
        fullAlbumDate
        adblock
        volumePercentage
        beautifulLyrics
      ];

      enabledCustomApps = with spicePkgs.apps; [
        marketplace
      ];
    };
}

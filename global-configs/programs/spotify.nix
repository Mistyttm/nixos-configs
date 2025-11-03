{
  pkgs,
  spicetify-nix,
  ...
}:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  # Allow unfree for spotify - handled at system level
  # nixpkgs.config should not be set in home-manager when using useGlobalPkgs

  imports = [ spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
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

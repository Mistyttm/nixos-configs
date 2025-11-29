# Shared values and configurations across all hosts
# This is a flake-parts module that sets up common values
{ inputs, ... }:
let
  homeVersion = "25.11"; # Update this when you update your NixOS version
  overlay-wallpaper-engine = import ../patches/wallpaper-engine-plugin;
in
{
  # Define supported systems for perSystem
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # Expose shared values via flake output for use in other modules
  flake.shared = {
    inherit homeVersion;
    overlays = {
      inherit overlay-wallpaper-engine;
    };
  };

  # Set up perSystem for formatter
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;
  };
}

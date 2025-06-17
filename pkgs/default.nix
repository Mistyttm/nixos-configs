final: prev:
let
  # Read the current directory
  entries = builtins.readDir ./.;

  # Filter to only directories that contain a default.nix
  packageDirs = prev.lib.filterAttrs (name: type:
    type == "directory" &&
    builtins.pathExists (./${name} + "/default.nix")
  ) entries;

  # Convert to packages
  packages = prev.lib.mapAttrs (name: _:
    prev.callPackage (./${name}) { }
  ) packageDirs;
in
packages

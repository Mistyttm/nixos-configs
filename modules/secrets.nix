{inputs, ...}: let
  secretsDir = ../secrets;
  secretFiles = builtins.readDir secretsDir;
  yamlFiles =
    inputs.nixpkgs.lib.filterAttrs (
      name: type: type == "regular" && inputs.nixpkgs.lib.hasSuffix ".yaml" name
    )
    secretFiles;
  secretNames =
    inputs.nixpkgs.lib.mapAttrs' (
      name: _: let
        baseName = inputs.nixpkgs.lib.removeSuffix ".yaml" name;
      in
        inputs.nixpkgs.lib.nameValuePair baseName (secretsDir + "/${name}")
    )
    yamlFiles;
in {
  flake.secrets = secretNames;
}

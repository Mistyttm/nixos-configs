{...}: {
  flake-file.inputs.mkdocs-flake = {
    url = "github:applicative-systems/mkdocs-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  perSystem = {...}: {
    documentation.mkdocs-root = ../.;
  };
}

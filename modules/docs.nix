{...}: {
  flake-file.inputs.mkdocs-flake = {
    url = "github:applicative-systems/mkdocs-flake";
  };

  perSystem = {...}: {
    documentation.mkdocs-root = ../.;
  };
}

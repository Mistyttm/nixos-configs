{...}: {
  flake-file.inputs.mkdocs-flake = {
    url = "github:applicative-systems/mkdocs-flake";
    group = "tooling";
  };

  perSystem = {...}: {
    documentation.mkdocs-root = ../.;
  };
}

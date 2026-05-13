# Flake layout

The flake is split into small module files under `modules/` and host-specific
definitions under `hosts/`.

## Top-level inputs

- `nixpkgs` provides the package set.
- `flake-parts` provides the flake module system.
- `home-manager` is wired in at the flake level.
- `mkdocs-flake` adds the documentation outputs.

## Useful commands

- `nix flake check`
- `nix build .#documentation`
- `nix run .#watch-documentation`

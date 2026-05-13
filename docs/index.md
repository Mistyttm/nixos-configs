# dendritic-test

This repository contains the Nix flake that builds the host and home-manager
configuration for this machine set.

## What is documented here

- The overall flake layout.
- The main build and validation commands.
- Notes about the NixOS and Home Manager modules as they are added.

## Build the docs

- `nix build .#documentation`
- `nix run .#watch-documentation`

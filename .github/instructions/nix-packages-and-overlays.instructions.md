---
description: "Use when editing package derivations or patch overlays. Covers final/prev overlay conventions, fetch hash requirements, meta fields, and anti-patterns specific to this repository."
name: "Nix Packages And Overlays"
applyTo:
  - "packages/**/*.nix"
  - "patches/**/*.nix"
---
# Nix Packages And Overlays

## Overlay Conventions

- Use overlay function args as final: prev: { ... }.
- Use final for dependencies and prev for overridden packages.
- Do not use legacy self/super overlay style.

## Derivation Conventions

- Prefer the appropriate builder (stdenv.mkDerivation, buildPythonPackage, buildGoModule, etc.).
- Use fetchers with SRI hash fields:
  - hash = "sha256-..."
  - not deprecated sha256 = "..."
- Include meta with at least description, homepage, license, and mainProgram when applicable.
- Use lib.licenses.<spdx> for license values.
- Do not use overrideAttrs or overridePythonAttrs inside [packages/](packages); modify derivations directly.

## Patch And Packaging Flow

- Update existing package files in place when asked to bump or fix packages.
- Do not create a new patch overlay unless explicitly requested.
- Keep changes minimal and avoid unrelated refactors.

## Reference

- [AGENTS.md](AGENTS.md)

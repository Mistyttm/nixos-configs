---
description: "Use when creating or editing custom NixOS or home-manager modules. Enforces options/config structure, mkIf gating, and nixpkgs-style module patterns used in this repo."
name: "NixOS Module Authoring"
applyTo:
  - "modules/**/*.nix"
---
# NixOS Module Authoring

- Follow nixpkgs module style with explicit lib. and pkgs. prefixes.
- Split modules into options and config sections.
- Add explicit type, default, and description for each new option.
- Use lib.mkEnableOption for boolean toggles.
- Gate module config with lib.mkIf config.<path>.enable when feature-gated.
- Prefer lib.mkMerge for composing config fragments.
- Avoid raw conditional attrset merges in config blocks.
- Avoid with lib; and with pkgs; at module top level.
- Avoid rec unless truly required; prefer let ... in.
- Avoid Import From Derivation patterns such as builtins.import on derivation outputs.

## Placement

- Shared logic belongs in [modules/](modules).
- Host-specific one-offs belong under [hosts/](hosts), not shared modules.
- If a new module is created, make sure it is aggregated in [modules/default.nix](modules/default.nix).

## Reference

- [AGENTS.md](AGENTS.md)

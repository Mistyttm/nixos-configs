---
name: nixos-config-maintainer
description: 'Maintain this multi-host NixOS flake safely. Use for host-specific config edits, shared module updates, package bumps, overlay fixes, validation planning, and commit-scope suggestions.'
argument-hint: 'Describe host, target files, intended outcome, and whether change is host-only or global.'
---

# NixOS Config Maintainer

Use this skill for implementation tasks in this repository where safety and scope are critical.

## Inputs To Collect

- Target host or shared scope (puppypc, mistylappytappy, thedogpark, thekennel, or global).
- Files/directories to edit.
- Whether behavior should apply to one host or all hosts.
- Whether secrets are involved.

## Operating Rules

- Treat [AGENTS.md](AGENTS.md) as the source of truth for repo behavior.
- Assume current machine is not the target host until hostname is checked.
- Prefer non-mutating validation over system changes.
- Keep edits minimal and avoid broad refactors unless requested.

## Procedure

1. Determine scope.
- Host-only change: keep edits under [hosts/](hosts).
- Shared change: use [global-configs/](global-configs), [modules/](modules), or [flake.nix](flake.nix) with extra validation.

2. Apply repository coding conventions.
- Modules: options/config split, mkIf/mkMerge/mkOption patterns.
- Overlays: final/prev form.
- Packages: hash SRI format and complete meta fields.
- Secrets: reference sops paths, never plaintext.

3. Validate at the right level.
- Targeted checks:
  - nix fmt
  - nix flake check
  - nix build .#hydraJobs.nixos.<affected-host>
- Shared-scope checks:
  - nix build .#hydraJobs.nixos.puppypc
  - nix build .#hydraJobs.nixos.mistylappytappy
  - nix build .#hydraJobs.nixos.thedogpark
  - nix build .#hydraJobs.nixos.thekennel

4. Prepare commit message guidance.
- Follow [COMMITTING.md](COMMITTING.md): <type>(<scope>): <description>
- Scope should match host or component touched.

## Guardrails

- Do not run nixos-rebuild switch/test/boot without explicit user instruction and host confirmation.
- Do not mutate services on a non-target machine.
- Do not edit flake.lock manually.
- Do not install tools imperatively; use comma for one-off tools.

## References

- [AGENTS.md](AGENTS.md)
- [README.md](README.md)
- [COMMITTING.md](COMMITTING.md)
- [justfile](justfile)

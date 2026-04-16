---
description: "Use when editing NixOS config files in this repository. Covers cross-host safety, blast-radius checks, non-destructive validation commands, and repository-wide Nix conventions."
name: "Nix Repo Safety"
applyTo: "**/*.nix"
---
# Nix Repo Safety

- Treat [AGENTS.md](AGENTS.md) as the authoritative project policy.
- Assume the shell is running on puppypc unless verified otherwise.
- Before any system-level command, run hostname and confirm the target host matches.
- Never run nixos-rebuild switch/test/boot unless the user explicitly asks and host is confirmed.
- Prefer evaluation/build commands instead of system mutation:
  - nix build .#nixosConfigurations.<host>.config.system.build.toplevel
  - nix build .#hydraJobs.nixos.<host>
  - nix flake check
- Do not edit flake.lock manually.
- Do not install ad-hoc tools with apt/brew/pip/npm/cargo. Use comma: , <tool>.
- Never place plaintext secrets in .nix files. Use sops references via config.sops.secrets."name".path.

## Blast Radius Rule

- If touching [global-configs/](global-configs), [modules/](modules), or [flake.nix](flake.nix), treat the change as multi-host.
- Validate all active hosts when practical:
  - nix build .#hydraJobs.nixos.puppypc
  - nix build .#hydraJobs.nixos.mistylappytappy
  - nix build .#hydraJobs.nixos.thedogpark
  - nix build .#hydraJobs.nixos.thekennel

## References

- [AGENTS.md](AGENTS.md)
- [README.md](README.md)
- [COMMITTING.md](COMMITTING.md)

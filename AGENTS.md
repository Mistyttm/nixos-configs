# AGENTS.md

This file provides context and instructions for AI coding assistants (GitHub Copilot) working in this repository.

---

## Repository Overview

This is a **NixOS flake-based** configuration repository managing multiple hosts under a single flake. All configuration is written in the **Nix expression language**. There is no application code — this is purely system/user environment configuration.

---

## Language & Tooling

- **Primary language:** Nix (`.nix` files make up ~99% of the repo)
- **Formatter:** `nixfmt` (run via `nix fmt` or `just fmt`)
- **Linter:** `deadnix` (finds unused Nix bindings)
- **Commit linting:** `commitizen` (enforces Conventional Commits)
- **Pre-commit hooks:** managed via `pre-commit-hooks.nix` — run automatically on commit
- **Task runner:** `just` (see `justfile` for available commands)
- **Dev shell:** enter with `nix develop` — this gives you `just` and all pre-commit hooks

### Formatter Rules

- Use `nixfmt` style — 2-space indentation, no tabs
- Run `nix fmt` before committing
- The CI will fail if files are not formatted

---

## Directory Structure

```
.
├── flake.nix              # Root: inputs, outputs, host definitions
├── flake.lock             # Locked inputs — do not edit manually
├── justfile               # Task runner commands
├── hosts/                 # Per-host NixOS + home-manager configs
│   ├── puppypc/           # Main desktop (AMD Ryzen 7 7800X3D, RTX 3090, KDE)
│   ├── mistylappytappy/   # Gaming laptop (KDE, portable Steam)
│   ├── thedogpark/        # Sydney VPS (Matrix, Minecraft, nginx, WireGuard)
│   └── thekennel/         # Home server (Jellyfin, *arr stack, Jovian KDE)
├── global-configs/        # Shared configs imported by multiple hosts
│   ├── fonts/
│   ├── programs/
│   ├── shell/
│   ├── system/
│   └── users/
├── modules/               # Custom NixOS/home-manager modules
│   └── default.nix        # Module aggregator — imported by every host
├── packages/              # Custom package derivations
├── patches/               # Package overlays/patches
│   ├── wallpaper-engine-plugin/
│   ├── libreoffice/
│   └── tdarr/
├── secrets/               # sops-nix encrypted secrets
├── tests/                 # NixOS VM tests
└── topology/              # nix-topology infrastructure diagrams
```

---

## Hosts

| Host | Role | Desktop | Notable Services |
|---|---|---|---|
| `puppypc` | Main desktop | KDE Plasma | WiVRn, SlimeVR, Steam, gaming |
| `mistylappytappy` | Gaming laptop | KDE Plasma | Steam, auto-cpufreq |
| `thedogpark` | Sydney VPS | Headless | Matrix Synapse, Minecraft, nginx, WireGuard, fail2ban, mailserver |
| `thekennel` | Home server | Jovian KDE | Jellyfin, Sonarr, Radarr, Prowlarr, qBittorrent, Jellyseerr, nginx, WireGuard, CUDA |

Each host has:
- `hosts/<name>/configuration.nix` — NixOS system config
- `hosts/<name>/home.nix` — home-manager config for `misty`
- Some hosts have additional user home files (e.g. `thedogpark/steam.nix`)

---

## Key Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | nixos-unstable — primary package set |
| `home-manager` | User environment management |
| `sops-nix` | Secrets management (age/GPG encrypted) |
| `spicetify-nix` | Spotify client theming |
| `nix-minecraft` | Minecraft server management |
| `nix-vscode-extensions` | VSCode extension overrides |
| `chaotic` | Chaotic-AUR Nix overlay (extra packages) |
| `nixos-hardware` | Hardware-specific modules |
| `auto-cpufreq` | CPU frequency management (laptop) |
| `simple-nixos-mailserver` | Mail server (thedogpark) |
| `nix-topology` | Infrastructure diagram generation |
| `nix-cachyos-kernel` | CachyOS kernel overlay (puppypc) |
| `firefox-addons` | Firefox extension management |
| `determinate` | Determinate Nix installer integration |
| `nixpkgs-extra` | Custom packages (SDDM theme etc.) |

---

## Cross-Host Awareness

> ### ⚠️ STOP AND READ THIS BEFORE RUNNING ANY SYSTEM COMMAND ⚠️
>
> **This repository manages configurations for multiple separate physical machines. You are almost certainly running on `puppypc` — the only machine the AI regularly has a shell on — while editing configs for a completely different host.**
>
> **Before running any system-level command, you MUST check which machine you are currently on:**
>
> ```bash
> hostname
> # or
> cat /etc/hostname
> ```
>
> The only host where it may be appropriate to run system commands directly is **`puppypc`**. For every other host (`mistylappytappy`, `thedogpark`, `thekennel`), you are **editing config files for a machine you are not on**. System commands will affect `puppypc`, not the target host.
>
> **Rules:**
>
> - **Do not run `nixos-rebuild switch` or `nixos-rebuild test`** without first running `hostname` and explicitly confirming the current machine matches the target host.
> - **Never assume the current hostname is the target host.** If you are editing `hosts/thekennel/` and `hostname` returns `puppypc`, those are different machines — any `nixos-rebuild` or `systemctl` call acts on `puppypc`.
> - **Do not run destructive system commands** (`systemctl restart`, `rm -rf /var/...`, `ip link`, etc.) based on config changes for any host that is not the current machine.
> - When build-testing a remote host's config, always use `nix build` to evaluate without applying: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
> - For remote deployment, this repo uses standard NixOS tooling. Do not shell out to deploy without explicit instruction.

---

## Coding Conventions

This repo follows the [nixpkgs coding conventions](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) closely, as the owner is a nixpkgs maintainer. The rules below are non-negotiable.

### Nix Style

- Use `let ... in` blocks to avoid repetition
- Prefer `lib.optional`/`lib.optionals` over inline `if ... then [...] else []` for conditional lists — **never** use a bare `if` with a `null` fallback in lists except when fixing a critical bug (and even then, add a follow-up TODO comment)
- Use `mkIf`, `mkMerge`, `mkOption` from `lib` when writing modules — **never** use raw attribute set conditionals (`// (if cond then {...} else {})`) inside module `config` blocks
- Options in modules must always have `type`, `default`, and `description`
- Use `inherit` where it reduces noise: `inherit system;` not `system = system;`
- Avoid bare `pkgs.writeText` in configs — prefer proper modules or packages
- Do not hardcode usernames — reference the `users` config from `global-configs/users/`
- Avoid `with lib;` and `with pkgs;` at the top level of modules — use explicit `lib.` and `pkgs.` prefixes for clarity (nixpkgs style)
- Do not use `rec` attribute sets unless necessary — use `let ... in` instead

### Overlay Conventions (nixpkgs style)

Overlays follow the nixpkgs convention:
- First argument is `final` (the fixed-point, fully-overlaid package set) — use for dependencies
- Second argument is `prev` (the previous layer) — use to access packages you are overriding

```nix
# Correct
final: prev: {
  myPackage = prev.callPackage ./packages/my-package.nix { };
  boost = prev.boost.override { python = final.python3; };
}

# Wrong — do not use self/super (older style)
self: super: { ... }
```

### Package Derivations (nixpkgs style)

Custom packages in `packages/` should follow nixpkgs derivation conventions:
- Use `stdenv.mkDerivation` or the appropriate language framework (`buildPythonPackage`, `buildGoModule`, etc.)
- Always include `meta` with at least `description`, `homepage`, `license`, and `mainProgram` (if applicable)
- Use `lib.licenses.<spdx>` for the license value — do not use bare strings
- Use `lib.maintainers` references if relevant
- Fetch sources with `fetchFromGitHub` (preferred) or `fetchurl` — always pin with a `hash` attribute (not the deprecated `sha256` string form)
- Do not use `overrideAttrs` or `overridePythonAttrs` inside `packages/` — change the derivation directly

```nix
# Preferred fetch style
src = fetchFromGitHub {
  owner = "example";
  repo = "myrepo";
  rev = "v1.2.3";
  hash = "sha256-...";
};

# Deprecated — do not use
sha256 = "0abc...";
```

### Module System (nixpkgs style)

- Use the `options` / `config` split pattern in every module — do not write modules that are just a flat attribute set of config values
- Use `lib.mkEnableOption` for boolean feature toggles: `enable = lib.mkEnableOption "my feature";`
- Use `lib.mkPackageOption` where a module exposes a configurable package
- Gate all `config` values behind `lib.mkIf config.<module>.enable` (or equivalent)
- Do not use `imports` to sneak config into a module — use proper options
- Avoid `builtins.import` (IFD — Import From Derivation) — this is disallowed in nixpkgs style and can break evaluation

### Secrets

- All secrets live in `secrets/` and are encrypted with **sops-nix**
- Never put plaintext secrets anywhere in `.nix` files
- Secret paths follow the pattern: `config.sops.secrets."secret-name".path`
- When referencing a new secret, add it to the relevant host's sops config block and the `secrets/` directory

### Modules

- `modules/default.nix` aggregates all custom modules — add new modules there
- Modules should use `options` + `config` pattern, not just inline config
- Host-specific one-off configs belong in `hosts/<name>/configuration.nix`, not in modules

### Overlays

- Per-host overlays are applied in the `nixpkgs.overlays` list inside each host's flake module block
- Global overlays (used by all hosts) are defined in the top-level `let` block in `flake.nix`
- Patch overlays live in `patches/` as separate `.nix` files imported via `import ./patches/<name>`

### Packages

- Custom derivations go in `packages/`
- Exported as `packages.x86_64-linux.<name>` in `flake.nix`
- Also exposed via the `overlay-dispatcharr` overlay for use inside host configs

---

## Commit Message Format

This repo enforces **Conventional Commits** via `commitizen`. See `COMMITTING.md` for full details.

```
<type>(<scope>): <description>
```

### Types

| Type | Use for |
|---|---|
| `feat` | New feature or service |
| `fix` | Bug fix |
| `chore` | Maintenance, formatting, dependency bumps |
| `refactor` | Code restructuring without behaviour change |
| `ci` | CI/CD workflow changes |
| `revert` | Reverting a previous commit |

### Scopes

- **Host names:** `puppypc`, `thekennel`, `thedogpark`, `mistylappytappy`
- **Components:** `flake`, `deps`, `nginx`, `workflows`, `modules`, `secrets`, `topology`, etc.

### Examples

```
feat(thekennel): add tdarr transcoding service
fix(thedogpark): correct nginx upstream block for matrix
chore(deps): update flake inputs
refactor(modules): extract wireguard config into shared module
ci: add dispatcharr package build check
```

---

## CI / GitHub Actions

Workflows live in `.github/workflows/`. Key workflows:

- **`build.yml`** — builds all `nixosConfigurations` via Hydra jobs (`hydraJobs.nixos`)
- **`update-flake.yml`** — runs `nix flake update` on a schedule and opens a PR
- **`update-topology.yml`** — rebuilds and commits topology SVGs

When adding a new host, ensure it is included in `hydraJobs` in `flake.nix` (it is auto-derived from `nixosConfigurations` via `builtins.mapAttrs`).

---

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/home.nix`
2. Add an entry to `nixosConfigurations` in `flake.nix` following the existing pattern
3. Include `./modules/default.nix` in the modules list
4. Add the host scope to `COMMITTING.md` scopes list
5. If the host has secrets, create the corresponding entries in `secrets/` and `.sops.yaml`
6. Add topology config in `topology/` if needed

---

## Adding a New Module

1. Create the module file under `modules/`
2. Import it in `modules/default.nix`
3. If it introduces new options, use `mkOption` with `type`, `default`, and `description`
4. Enable it per-host via the option you defined

---

## Adding a New Package

1. Create the derivation in `packages/<name>.nix`
2. Export it in `packages.x86_64-linux` in `flake.nix`
3. Add it to the `overlay-dispatcharr` (or create a new overlay) if hosts need it via `pkgs.<name>`
4. Reference via `pkgs.<name>` in the relevant host config

---

## What Copilot Should NOT Do

- **Do not run `nixos-rebuild switch/test/boot`** without first running `hostname` to confirm the current machine matches the target host — editing `hosts/thekennel/` on `puppypc` and running `nixos-rebuild` would modify the wrong machine. **You are almost always on `puppypc`.**
- **Do not run any system-mutating commands** (`systemctl`, `rm -rf /var/...`, `ip`, etc.) based on config edits for a non-current host — those commands affect whichever machine the shell is on, not the edited host. **Check `hostname` first.**
- **Do not edit `flake.lock`** — it is managed by `nix flake update` (see note below)
- **Do not install tools with `apt`, `brew`, `pip install -g`, `npm install -g`, or `cargo install`** — this is NixOS. Use `,` (comma) for ad-hoc tool access. See the *Running CLI Tools with Nix Comma* section.
- **Do not suggest the user install anything imperatively** — just use `,`.
- **Do not put secrets or tokens in `.nix` files** — use sops-nix
- **Do not use the deprecated `sha256 = "..."` string form** in fetchers — use `hash = "sha256-..."` (SRI format)
- **Do not add `allowUnfree = true` globally** — scope it to specific packages using `nixpkgs.config.allowUnfreePredicate`
- **Do not use `with lib;` or `with pkgs;`** at module top-level — use explicit prefixes
- **Do not use `rec` attribute sets** where a `let ... in` block would work
- **Do not introduce Import From Derivation (IFD)** — no `builtins.import` on derivation outputs
- **Do not remove `deadnix`-flagged bindings without checking** — they may be needed by host-specific code not visible in the current file
- **Do not modify topology SVGs directly** — they are generated; run `nix build .#topology.x86_64-linux.config.output`
- **Do not use `overrideAttrs` inside `packages/`** — modify the derivation source directly
- **When asked to update a package, edit it in-place** in its own `.nix` file — do not create a patch overlay or a new file unless explicitly asked to do so

---

## Tracking nixos-unstable

This repo tracks `nixos-unstable` and the `flake.lock` is kept up to date via an automated workflow that runs every 12 hours. This has a practical consequence for troubleshooting:

**If hashes don't match or a build fails with a hash mismatch, do not attempt to manually fix the hash.** The most likely cause is that `flake.lock` has been updated on `main` since your last pull. Run:

```bash
git pull
```

and retry. The updated lockfile will almost always resolve it. Only investigate further if the mismatch persists after pulling.

Do not try to recompute or patch hashes in `flake.lock` manually — the file is fully managed by `nix flake update` and the `update-flake.yml` workflow, which runs every 12 hours.

---

## Blast Radius Awareness

Some parts of this repo affect every host simultaneously. Before making changes to the following, consider whether the change is truly intended to apply everywhere:

- **`global-configs/`** — imported by all hosts. A change here affects `puppypc`, `mistylappytappy`, `thedogpark`, and `thekennel` equally. If the intent is host-specific, the change belongs in `hosts/<hostname>/` instead.
- **`modules/`** — all custom modules are aggregated via `modules/default.nix` and imported by every host. A broken module will break every host's build.
- **`flake.nix` inputs/outputs** — changes to the top-level flake affect all hosts. Errors here will prevent any host from evaluating.

When making a change that touches any of the above, always verify it builds for all hosts before committing:

```bash
nix build .#hydraJobs.nixos.puppypc
nix build .#hydraJobs.nixos.mistylappytappy
nix build .#hydraJobs.nixos.thedogpark
nix build .#hydraJobs.nixos.thekennel
```

---

## When Uncertain

This is a personal configuration repository — many choices are deliberate and non-obvious. When something looks unusual or unconventional, assume it is intentional before changing it.

If a task is ambiguous (e.g. it's unclear whether a change should apply to one host or all hosts, whether a new option should be a module or inline config, or whether a secret reference already exists), **stop and ask rather than guess**. A wrong assumption here can break real running systems.

When making a best-effort change where something is genuinely unclear, leave an inline comment flagging the assumption:

```nix
# ASSUMPTION: applying to all hosts — confirm if this should be puppypc-only
```

Prefer **minimal, conservative changes** — do the smallest thing that satisfies the request. Do not refactor surrounding code, rename things, or reorganise files unless explicitly asked.

---

## File Creation Rules

- **New host config:** `hosts/<hostname>/configuration.nix` + `hosts/<hostname>/home.nix` — always a directory, never a flat file
- **New module:** a file under `modules/`, imported in `modules/default.nix` — never a standalone file that isn't aggregated
- **New package:** `packages/<name>.nix` — single file unless it's a multi-file derivation, in which case use `packages/<name>/default.nix`
- **New patch overlay:** `patches/<name>/default.nix` following the pattern of existing entries in `patches/`
- **Do not create new top-level directories** without explicit instruction — the structure is intentional
- When a single `default.nix` is sufficient, do not split into multiple files

---

## Context Copilot Cannot See

- **`secrets/`** contains sops-encrypted binary files. They will appear as unreadable binary content. Do not attempt to read, modify, or suggest edits to these files directly. Secret *references* in `.nix` files (via `config.sops.secrets."name".path`) are fine to add.
- **`flake.lock`** is a large JSON file managed entirely by `nix flake update`. Individual hash values inside it are not meaningful in isolation — do not attempt to interpret or patch specific entries.
- **`topology/`** SVG files are generated outputs. Do not edit them directly.
- **`.sops.yaml`** controls which age/GPG keys can decrypt which secrets — only edit this if explicitly asked, and understand that a mistake here can make secrets permanently unreadable.

---

## External References

When in doubt about nixpkgs conventions not covered here:

- [nixpkgs CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) — canonical style and contribution rules
- [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/) — stdenv, fetchers, builders, language frameworks
- [NixOS module system](https://nixos.org/manual/nixos/stable/#sec-writing-modules) — options, types, mkIf, mkMerge
- [home-manager option search](https://home-manager-options.extranix.com/) — all available home-manager options
- [NixOS option search](https://search.nixos.org/options) — all available NixOS module options

---

## Running CLI Tools with Nix Comma

This repo runs on NixOS. **Do not install tools via `apt`, `brew`, `pip install -g`, `npm install -g`, `cargo install`, or any other imperative package manager.** All ad-hoc CLI tools are accessed through **[nix-community/comma](https://github.com/nix-community/comma)** (`comma` / `,`), which runs any package from nixpkgs without installing it permanently.

### CRITICAL RULES

1. **Before running any unfamiliar CLI tool, check if it is available in your `PATH`.** If it is not, use `,` to run it through comma — never suggest installing it.
2. **Never use `nix shell` or `nix run` directly for ad-hoc tool use.** Use `,` instead — it uses `nix-index` to find the right package automatically.
3. **On "command not found"**: Do NOT advise installation. Immediately retry with `,`.
4. **Do not add tools to any NixOS config just to use them for a one-off task** — that is exactly what comma is for.

### Usage

```bash
# Run any command from nixpkgs, auto-resolved by comma:
, <command> [args...]

# Examples:
, jq '.name' data.json
, fd '\.nix$' .
, rg 'TODO' .
, pandoc README.md -o README.pdf
, shellcheck script.sh
, ffmpeg -i input.mp4 output.gif
, nix-tree   # inspect the nix store
, nix-diff /nix/store/abc... /nix/store/def...

# If comma prompts you to choose between multiple packages, pick the most
# appropriate one (usually the top-level package, not a -dev or -lib variant).
```

### How Comma Works

Comma uses `nix-index` to locate which nixpkgs package provides a given binary, then invokes `nix run` with that package. The nix store acts as the cache — subsequent invocations of the same tool are fast. The `nix-index` database is kept up to date on this system; if a lookup fails, run:

```bash
nix-index
```

to refresh it before retrying.

### When Comma Cannot Find a Tool

If `,` exits with "not found in nix-index", the package may be named differently from its binary. Search nixpkgs:

```bash
nix search nixpkgs <keyword>
```

Then run with an explicit package name:

```bash
nix run nixpkgs#<package-name> -- [args...]
```

### Recap: Comma vs. Permanent Installation

| Situation | What to do |
|---|---|
| One-off or exploratory tool use | `, <tool> [args]` |
| Tool needed persistently in a host's environment | Add to the appropriate `hosts/<n>/` or `global-configs/` config |
| Tool needed in the dev shell | Add to `devShells` in `flake.nix` |
| Build-time tool in a derivation | Add to `nativeBuildInputs` in the package derivation |

---

## Useful Commands

```bash
# Enter dev shell (gives you just + pre-commit hooks)
nix develop

# Format all Nix files
nix fmt

# Build a specific host config
nix build .#nixosConfigurations.puppypc.config.system.build.toplevel

# Build all hosts (like CI)
nix build .#hydraJobs.nixos.puppypc

# Run tests
nix build .#checks.x86_64-linux.dispatcharr

# Rebuild topology diagrams
nix build .#topology.x86_64-linux.config.output

# Update flake inputs
nix flake update

# Run pre-commit hooks manually
pre-commit run --all-files
```

# AGENTS.md

Guidance for AI coding agents working in this repository.

## Hard rules (non-negotiable)

- **Never commit or push.** The agent may edit files in the working
  tree, but must never run `git commit`, `git push`, `git rebase`, or
  anything else that alters git history — the user reviews and commits
  all changes themselves. Staging (`git add`) for the user to review is
  fine; committing on their behalf is not.
- **Never write a secret.** The agent cannot create, edit, or decrypt
  entries in `secrets/*.yaml` — sops encryption keys aren't available
  to it, and secret values must only ever be entered by the user. If a
  change needs a new secret: wire up the consuming module exactly as if
  the secret already existed (`sops.secrets."<name>" = { sopsFile =
  self.secrets.<file>; };` etc.), then tell the user which key(s) they
  need to add and to which `secrets/<file>.yaml`, e.g. via `sops
  secrets/<file>.yaml`. Don't invent placeholder values.
- **Check command availability with `comma` before assuming a tool is
  missing.** Every system this repo runs on has `,` (nix-community's
  `comma`) available, which runs a program from nixpkgs on demand
  without installing it — e.g. `, nixfmt --check .` or `, deadnix .`.
  If unsure whether a CLI tool is present, try it directly first; if
  it's genuinely absent, prefix it with `,` rather than concluding the
  command can't be run.
- **Search nixpkgs before guessing how a module or package works.**
  Never write option names, service config shapes, or package
  attributes/build inputs from memory when unsure — nixpkgs moves fast
  and training data goes stale or is flatly wrong about option names,
  defaults, and available services/packages. Before depending on
  specific behavior of an upstream NixOS/home-manager module or a
  nixpkgs package, look it up rather than assume:
  - **`nh search` is the first tool to reach for** — it's already part
    of this repo's toolchain (`programs.nh.flake` is enabled; see the
    `rebuild` shell alias in `hosts/thekennel/configuration.nix`) and
    can look up packages, NixOS options, and other nixpkgs content
    directly from the shell without leaving the terminal.
  - If `nh search` doesn't resolve it, fall back to `search.nixos.org`
    or a general web search for the current option tree, or read the
    actual module/package source in `nixpkgs` on GitHub
    (`NixOS/nixpkgs`) — fetch specific files via
    `raw.githubusercontent.com` (in the network allowlist) rather than
    a full clone, which is enormous; a shallow `git clone
    --depth 1 --filter=blob:none --sparse` of just the relevant
    subtree is the next option if browsing raw files isn't enough.
  - This applies both to referencing upstream options (e.g.
    `services.jellyfin.*`) in a feature module and to writing/editing a
    `packages/<name>/package.nix` derivation.
  - If none of this resolves the uncertainty (e.g. the sandbox can't
    reach the needed source), say so plainly and ask rather than
    filling in a guessed option name or attribute.

## What this repo is

A personal NixOS/home-manager flake collection using the **dendritic
pattern**: instead of a hand-maintained tree of `imports`, every `.nix`
file under `modules/` is a self-contained **flake-parts module**, and
`vic/import-tree` recursively discovers and imports all of them
automatically from `flake.nix`:

```nix
outputs = inputs: let
  modules = inputs.import-tree ./modules;
in
  inputs.flake-parts.lib.mkFlake {inherit inputs;} (modules // {...});
```

### Deviation from canonical Dendritic: attribute scheme

Canonical Dendritic (per [dendrix.denful.dev/Dendritic.html](https://dendrix.denful.dev/Dendritic.html))
registers modules per-*aspect*-across-*classes* under
`flake.modules.<class>.<aspect>`, e.g. `flake.modules.nixos.ssh` +
`flake.modules.homeManager.ssh` in the *same file*. **This repo does not
use that scheme.** It uses the older/alternate flat attribute paths
instead:

- `flake.nixosModules.<name>` (NixOS class)
- `flake.homeModules.<name>` (home-manager class)

There is no `flake.modules.*` anywhere in this repo — do not introduce
it. When adding a new aspect that needs both a NixOS and a home-manager
side (the canonical example is one file defining both classes for the
same aspect), this repo's convention is still two separate registrations
in the same file if convenient, but under `flake.nixosModules.<name>` /
`flake.homeModules.<name>`, not `flake.modules.nixos.<name>` /
`flake.modules.homeManager.<name>`. Match whichever attribute scheme is
already used by neighboring files — never mix the two schemes.

Everything else about the pattern — one file = one flake-parts module,
no manual import list, `import-tree` auto-discovery, feature-centric
(not host-centric) organization, avoiding `specialArgs` in favor of
let-bindings/custom options — is followed as canonically described.
This repo does not currently use import-tree's `_`-in-path ignore
convention (no file/dir path contains a leading `_`); if asked to
temporarily disable a file without deleting it, that convention is
available (any path segment starting with `_` is skipped by
`import-tree`) but hasn't been used here yet — flag it as a new
convention if introducing it, rather than assuming it's already relied
upon elsewhere.

Consequences for agents:

- **Adding a new file under `modules/` is enough to wire it in.** There
  is no central list of imports to edit. File location doesn't imply
  usage — only being referenced by `self.nixosModules.<name>` /
  `self.homeModules.<name>` (directly or transitively from a host's
  `configuration.nix`) makes a module part of a build.
- File and directory names under `modules/` are organizational only —
  Nix doesn't care about them. What matters is the attribute name each
  file registers under `flake.nixosModules.*` / `flake.homeModules.*`.
- Every file is a flake-parts module and therefore an attrset (or a
  function returning one) shaped like `{ config = ...; }`,
  `{ perSystem = ...; }`, `{ flake.nixosModules.foo = ...; }`, etc. —
  not a bare NixOS module. Don't write a raw
  `{ config, lib, pkgs, ... }: { ... }` NixOS module at the top level of
  a file in `modules/`; wrap it as `flake.nixosModules.<name> = { ... }: { ... }`.

## Directory map

```
flake.nix                      # inputs, nixConfig (binary caches), import-tree wiring
modules/
  parts.nix                    # flake-parts `systems` list
  packages.nix                 # overlay wiring packages/*/package.nix, perSystem pkgs
  secrets.nix                  # auto-registers flake.secrets.<name> from secrets/*.yaml
  checks.nix                   # formatter + pre-commit hooks (alejandra, deadnix)
  devshells.nix                # `nix develop` shell (numtide/devshell)
  docs.nix                     # mkdocs-flake root wiring (docs/ + mkdocs.yml)
  topology.nix                 # nix-topology network diagram definition
  hydra.nix                    # CI/hydra jobset aggregating all nixosConfigurations
  nixos/                       # standalone custom NixOS service modules
                                # (services.jellystat, services.cleanuparr, etc.)
  features/
    nixosModules/               # reusable NixOS feature modules (flake.nixosModules.*)
      system-essentials/        # base system: bootloader, locale, sops, networking/*
      desktops/, gaming/, hardware/, docker/, arrStack/, ...
    homeModules/                 # reusable home-manager modules (flake.homeModules.*)
      users/misty.nix, git.nix, zsh.nix, starship/, ...
  hosts/
    <hostname>/
      default.nix               # registers flake.nixosConfigurations.<hostname>
      configuration.nix         # flake.nixosModules.<hostname>Configuration: imports
                                 # features + host-specific config, by convention named
                                 # `flake.nixosModules.<hostname>Configuration`
      hardware.nix              # flake.nixosModules.<hostname>Hardware (hardware-scan output)
      home-manager.nix          # flake.nixosModules.<hostname>HomeManager (per-user HM config)
packages/                       # custom package derivations, one dir per package,
                                 # each with package.nix; auto-overlayed via packages.nix
secrets/                        # sops-nix encrypted secrets, one YAML per service/domain
docs/, mkdocs.yml               # documentation site (mkdocs-flake)
topology/                       # generated network diagram SVGs (nix-topology output)
```

Hosts currently defined: `puppypc` (main desktop), `puppylaptop` /
`mistylappytappy` (gaming laptop), `thedogpark` (Sydney VPS), `thekennel`
(home server/media stack), `thepetshop`.

Note: this repo does **not** use `vic/flake-file` (the optional
canonical-Dendritic tool that lets each module contribute its own flake
`inputs`). All flake inputs are declared by hand in the single
`inputs = { ... }` block in `flake.nix`. When a change needs a new
flake input, add it there directly — don't introduce `flake-file.inputs.*`
scattered across `modules/` unless explicitly asked to adopt it.

## Module conventions

### Registering a module

- NixOS feature module: `flake.nixosModules.<camelCaseName> = { ... }: { ... };`
- Home-manager module: `flake.homeModules.<camelCaseName> = { ... }: { ... };`
- Reference other modules via `self.nixosModules.<name>` /
  `self.homeModules.<name>` in a file's `imports`, using the `self`
  flake-parts arg (not relative-path imports of raw files).
- A host's `hosts/<name>/default.nix` builds the actual
  `nixosConfigurations.<name>` from exactly one module:
  `self.nixosModules.<name>Configuration`. That configuration module's
  own `imports` list is the single place enumerating which features a
  host gets.

### The "profile" pattern

Several networking/service modules (see `wireguard.nix`, `nginx.nix`)
define **one module with an internal `profiles.<hostname>` attrset**
rather than per-host files. The module reads `config.networking.hostName`
(or an explicit `doggate.<feature>.profile` override) to select its
profile, then gates the real config behind
`config = lib.mkIf (cfg.enable && profile != null) { ... };`. When
adding host-specific networking/service behavior for an existing
`doggate.*`-namespaced feature, extend that module's `profiles` set
rather than creating a new per-host module.

Custom options in this repo live under the `doggate.*` namespace
(e.g. `doggate.nginx.enable`, `doggate.wireguard.profile`) — this is
the project's own option namespace, distinct from upstream NixOS
module options.

### Packages

- `packages/<name>/package.nix` is a `callPackage`-style derivation
  file. `modules/packages.nix` auto-discovers every directory under
  `packages/` and exposes it as `final.<name>` via `flake.overlays.default`
  — no manual registration needed beyond creating the directory.
- `perSystem.pkgsDirectory` (via `pkgs-by-name-for-flake-parts`) also
  exposes these as flake-level packages.
- **Every package must be written as a `finalAttrs`-style set**, i.e.
  `stdenv.mkDerivation (finalAttrs: { ... })`, referring back to
  `finalAttrs.<attr>` / `finalAttrs.finalPackage` where a derivation
  needs to self-reference (version, pname, passthru, etc.) rather than
  a plain non-recursive attrset. Don't write `stdenv.mkDerivation
  rec { ... }` or a flat attrset for new or edited packages.

### Overlays

- **All overlays must be written `final: prev: ...`** — always name
  both arguments `final` and `prev` (not `self`/`super`, not `_prev`
  when it's actually used, not omitted). `modules/packages.nix`'s
  `flake.overlays.default` should follow this shape; keep any new
  overlay consistent with it even if one of the two arguments goes
  unused in that particular overlay (use `final: _prev: ...` /
  `_final: prev: ...` only when an argument is genuinely unused, never
  rename them to something else).

### Secrets (sops-nix)

- The agent never creates, edits, or decrypts anything under
  `secrets/*.yaml` — see "Hard rules" above. Only the user runs `sops
  secrets/<name>.yaml` to add or edit secret values.
- When a change needs a secret: reference it as if it already exists
  (`self.secrets.<file>` as the `sopsFile`, `sops.secrets."<key>"` for
  the entry) — `modules/secrets.nix` auto-registers any
  `secrets/<name>.yaml` as `self.secrets.<name>`, so no separate
  wiring is needed there — then explicitly tell the user which file
  and key(s) to add.

### Custom NixOS service modules (`modules/nixos/`)

Standalone service modules not tied to the dendritic feature tree
(e.g. `jellystat.nix`, `cleanuparr.nix`) follow standard NixOS module
conventions internally (`options.services.<name>`, `config = lib.mkIf
cfg.enable { ... }`) but are still wrapped in
`flake.nixosModules.<name> = { ... }: { ... };` like everything else.

## Formatting, linting, checks

- Formatter: `alejandra` (invoke via `nix fmt`).
- Lint: `deadnix` (auto-edit enabled in pre-commit).
- Pre-commit hooks run both; `commitizen` is currently disabled (Python
  3.14 compatibility issue — don't re-enable without checking that).
- Dev shell: `nix develop` provides `just`, `nixfmt`, `deadnix`, and an
  `fmt` command (`nix fmt`) that runs formatting.
- Commit messages **must** follow Conventional Commits — see
  `COMMITTING.md`. Format: `<type>(<scope>): <description>`, types are
  `feat`/`fix`/`chore`/`refactor`/`ci`/`revert`; scopes are typically a
  hostname or component name.

## Validating changes

Before treating a change as done, prefer actually evaluating it over
eyeballing Nix syntax:

```sh
nix flake check                          # runs checks.* incl. pre-commit hooks
nix build .#nixosConfigurations.<host>.config.system.build.toplevel  # host builds
nix fmt                                  # format all .nix files
```

`nix-cli-setup` (if available in this environment) can install Nix into
a sandbox that doesn't already have it, to make these commands usable.
If a supporting CLI tool (`nixfmt`, `deadnix`, `just`, etc.) seems
unavailable outside the dev shell, don't assume it's missing — try
running it via `comma` first, e.g. `, nixfmt --check path/to/file.nix`
or `, deadnix .`, since `,` is available on every system this repo is
used on.

`nh` (the "yet another nix helper" CLI) is available for general use
on these systems, not just `nh search` — e.g. `nh os build .` to build
a host's config without activating it, `nh os switch . -H <host>`
(what the `rebuild` alias does) to activate one, `nh clean`, etc.
`nh os build` is a safe way to sanity-check a host actually evaluates
and builds. `nh os switch`/`nh os boot` activate a configuration on
the real running system they're executed on — treat those the same
way as git commits: fine to mention or suggest, but don't run them
unprompted on the user's behalf.

## Things to be careful about

- **`flake.lock` / inputs**: several inputs are pinned to forks or
  specific branches (e.g. `nix-cachyos-kernel/release`,
  `millennium?dir=packages/nix`). Don't "helpfully" repoint these to
  upstream defaults without being asked.
- **Host hardware/network files** (`hosts/*/hardware.nix`, the
  `wireguard.nix` profile keys/IPs) encode real machine UUIDs, WireGuard
  public keys, and internal network topology. Treat them as
  infrastructure-sensitive even though public keys aren't secret.
- **`secrets/*.yaml`** are sops-encrypted; agents cannot and should not
  attempt to decrypt or read their contents.
- **`topology/*.svg`** are generated artifacts (`nix build
  .#topology.x86_64-linux.config.output`), not hand-edited.
- The repo owner explicitly notes the dendritic conversion is recent
  and documentation/tests may lag behind actual structure — when in
  doubt, grep for an existing similar module and match its shape rather
  than assuming a convention from this file is exhaustive.

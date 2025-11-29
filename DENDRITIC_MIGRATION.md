# Dendritic NixOS Configuration Migration Plan

## Overview

This document outlines the migration plan to convert this NixOS configuration to follow the Dendritic pattern, using flake-parts for a more modular, aspect-oriented architecture.

**Migration Date Started:** 29 November 2025  
**Current Branch:** dendritic-test  
**Status:** Planning Phase

## What is Dendritic?

Dendritic is a configuration pattern for Nix flakes where:
- Every `.nix` file is a flake-parts module
- Configuration is organized by **aspects/features** rather than hosts
- Each aspect spans multiple configuration classes (NixOS, home-manager, etc.)
- No manual imports - all modules auto-loaded
- Values shared via flake-parts config instead of specialArgs

**Key Resources:**
- [Dendritic Documentation](https://dendrix.oeiuwq.com/Dendritic.html)
- [GitHub Repository](https://github.com/mightyiam/dendritic)
- [flake.parts Documentation](https://flake.parts/)

---

## Complete Migration Checklist

### Phase 1: Infrastructure Setup

#### Core Structural Changes

- [ ] **1.1** Add `flake-parts` to flake inputs
- [ ] **1.2** Add `import-tree` (or flake-parts-lib) for auto-loading modules
- [ ] **1.3** Restructure `flake.nix` to use `flake-parts.lib.mkFlake`
- [ ] **1.4** Minimize `flake.nix` to be just a manifest of inputs and entry point
- [ ] **1.5** Test that flake evaluation works with basic flake-parts setup

#### Module Structure

- [ ] **1.6** Create new `modules/` directory structure (can coexist with old during migration)
- [ ] **1.7** Set up subdirectories: `modules/aspects/`, `modules/hosts/`, `modules/users/`, `modules/system/`
- [ ] **1.8** Configure import-tree to load all modules recursively
- [ ] **1.9** Verify module auto-loading works

### Phase 2: Simple Aspect Migration

Start with standalone aspects that have minimal dependencies.

#### Git Aspect
- [ ] **2.1** Create `modules/aspects/git.nix` as flake-parts module
- [ ] **2.2** Convert home-manager git config to `flake.modules.homeManager.git`
- [ ] **2.3** Add system-level git packages to `flake.modules.nixos.git`
- [ ] **2.4** Test git aspect on one host

#### Shell/CLI Aspects
- [ ] **2.5** Create `modules/aspects/zsh.nix`
- [ ] **2.6** Create `modules/aspects/cli-tools.nix` (bat, eza, ripgrep, etc.)
- [ ] **2.7** Create `modules/aspects/starship.nix` or `modules/aspects/oh-my-posh.nix`
- [ ] **2.8** Test shell aspects on one host

#### Fonts Aspect
- [ ] **2.9** Create `modules/aspects/fonts.nix`
- [ ] **2.10** Combine system fonts with home-manager font config
- [ ] **2.11** Test fonts on one host

#### Simple Program Aspects
- [ ] **2.12** Create `modules/aspects/vscode.nix`
- [ ] **2.13** Create `modules/aspects/spotify.nix`
- [ ] **2.14** Create `modules/aspects/thunderbird.nix`
- [ ] **2.15** Create `modules/aspects/browsers.nix`
- [ ] **2.16** Test each program aspect

### Phase 3: System Aspects Migration

#### Locale and i18n
- [ ] **3.1** Create `modules/system/locale.nix`
- [ ] **3.2** Migrate locale settings from current system config
- [ ] **3.3** Test locale on one host

#### Boot and System Base
- [ ] **3.4** Create `modules/system/bootloader.nix`
- [ ] **3.5** Create `modules/system/nixoptions.nix`
- [ ] **3.6** Create `modules/system/zram.nix`
- [ ] **3.7** Test system base on one host

#### Networking Aspects
- [ ] **3.8** Create `modules/aspects/networking.nix` (base networking)
- [ ] **3.9** Create `modules/aspects/ssh.nix` (server + client config)
- [ ] **3.10** Create `modules/aspects/bluetooth.nix`
- [ ] **3.11** Test networking on one host

#### Audio and Printing
- [ ] **3.12** Create `modules/aspects/audio.nix`
- [ ] **3.13** Create `modules/aspects/printing.nix`
- [ ] **3.14** Test on desktop host

### Phase 4: Complex Aspects Migration

#### Desktop Environment
- [ ] **4.1** Create `modules/aspects/kde.nix`
- [ ] **4.2** Migrate KDE Plasma settings
- [ ] **4.3** Migrate SDDM configuration
- [ ] **4.4** Handle kwin-effects-forceblur integration
- [ ] **4.5** Test KDE on desktop hosts

#### Gaming
- [ ] **4.6** Create `modules/aspects/gaming/` directory
- [ ] **4.7** Create `modules/aspects/gaming/steam.nix`
- [ ] **4.8** Create `modules/aspects/gaming/mangohud.nix`
- [ ] **4.9** Split mangohud per-game configs into incremental modules
- [ ] **4.10** Handle Jovian integration for Steam Deck hosts
- [ ] **4.11** Test gaming on puppypc and thekennel

#### Virtualization
- [ ] **4.12** Create `modules/aspects/virtualization.nix`
- [ ] **4.13** Migrate Docker, libvirt, etc. configurations
- [ ] **4.14** Test on hosts that use virtualization

#### Mail
- [ ] **4.15** Create `modules/aspects/mail.nix`
- [ ] **4.16** Combine mailserver (nixos) and thunderbird (home-manager)
- [ ] **4.17** Handle secrets integration with sops-nix
- [ ] **4.18** Test on thedogpark

### Phase 5: User Aspects

#### User Configuration
- [ ] **5.1** Create `modules/users/misty.nix`
- [ ] **5.2** Create `modules/users/steam.nix`
- [ ] **5.3** Create `modules/users/wagtailpsychology.nix`
- [ ] **5.4** Define user-specific aspects and home configs
- [ ] **5.5** Eliminate extraSpecialArgs usage

### Phase 6: Host Configuration Migration

#### Convert Host Configurations
- [ ] **6.1** Create `modules/hosts/puppypc.nix` (desktop gaming PC)
- [ ] **6.2** Create `modules/hosts/mistylappytappy.nix` (laptop with work user)
- [ ] **6.3** Create `modules/hosts/thedogpark.nix` (server with mailserver, matrix)
- [ ] **6.4** Create `modules/hosts/thekennel.nix` (Steam Deck)
- [ ] **6.5** Create `modules/hosts/foodbowl.nix` (Raspberry Pi 4, aarch64)

#### Host-Specific Configurations
- [ ] **6.6** Migrate hardware-configuration.nix for each host
- [ ] **6.7** Handle architecture differences (x86_64 vs aarch64)
- [ ] **6.8** Migrate host-specific services (pihole, minecraft, matrix, etc.)
- [ ] **6.9** Handle Jovian modules for gaming devices
- [ ] **6.10** Handle nixos-hardware for Raspberry Pi

### Phase 7: Services Migration

#### Server Services (thedogpark)
- [ ] **7.1** Create `modules/aspects/services/nginx.nix`
- [ ] **7.2** Create `modules/aspects/services/matrix.nix`
- [ ] **7.3** Create `modules/aspects/services/minecraft.nix`
- [ ] **7.4** Create `modules/aspects/services/mailserver.nix`
- [ ] **7.5** Migrate security services (fail2ban, crowdsec, clamav)

#### Home Services (foodbowl)
- [ ] **7.6** Create `modules/aspects/services/pihole.nix`
- [ ] **7.7** Test services on respective hosts

### Phase 8: Remove specialArgs

#### Eliminate specialArgs Usage
- [ ] **8.1** Remove `specialArgs` from all nixosSystem calls
- [ ] **8.2** Remove `extraSpecialArgs` from all home-manager configs
- [ ] **8.3** Replace with flake-parts level let bindings
- [ ] **8.4** Replace with config.flake.* references
- [ ] **8.5** Specifically remove: homeVersion, spicetify-nix, kwin-effects-forceblur passing
- [ ] **8.6** Test that all hosts still build

### Phase 9: Testing & Validation

#### Build Testing
- [ ] **9.1** Test build puppypc: `nixos-rebuild build --flake .#puppypc`
- [ ] **9.2** Test build mistylappytappy: `nixos-rebuild build --flake .#mistylappytappy`
- [ ] **9.3** Test build thedogpark: `nixos-rebuild build --flake .#thedogpark`
- [ ] **9.4** Test build thekennel: `nixos-rebuild build --flake .#thekennel`
- [ ] **9.5** Test build foodbowl: `nixos-rebuild build --flake .#foodbowl`

#### Validation
- [ ] **9.6** Run `nix flake check`
- [ ] **9.7** Verify all overlays still work
- [ ] **9.8** Verify secrets management (sops-nix) still works
- [ ] **9.9** Check that chaotic-nyx integration works
- [ ] **9.10** Verify cachix substituters work

#### Live Testing
- [ ] **9.11** Deploy to test host and verify functionality
- [ ] **9.12** Test home-manager switch for each user
- [ ] **9.13** Verify services start correctly
- [ ] **9.14** Check gaming functionality (Steam, etc.)
- [ ] **9.15** Verify desktop environment works

### Phase 10: Cleanup

#### Remove Old Structure
- [ ] **10.1** Remove `global-configs/` directory
- [ ] **10.2** Remove old `modules/default.nix` import structure
- [ ] **10.3** Clean up host-specific old home.nix files
- [ ] **10.4** Remove any temporary migration files
- [ ] **10.5** Update .gitignore if needed

#### Documentation
- [ ] **10.6** Update README.md with new structure
- [ ] **10.7** Document how to add new aspects
- [ ] **10.8** Document how to add new hosts
- [ ] **10.9** Add examples for common tasks
- [ ] **10.10** Document which aspects each host uses

### Phase 11: Advanced Optimizations (Optional)

#### Optional Enhancements
- [ ] **11.1** Consider using `flake-file` for distributed input management
- [ ] **11.2** Split large aspects into incremental modules
- [ ] **11.3** Create reusable aspect profiles (e.g., "developer", "gamer", "server")
- [ ] **11.4** Extract generic aspects for community sharing
- [ ] **11.5** Set up perSystem for custom packages

---

## Detailed Migration Plan

### Week 1: Infrastructure & Simple Aspects

**Goals:**
- Set up flake-parts infrastructure
- Migrate simple standalone aspects
- Test on one host (puppypc recommended)

**Tasks:**
1. Add flake-parts and import-tree to inputs
2. Restructure flake.nix to use mkFlake
3. Create new modules/ directory structure
4. Migrate git, zsh, fonts aspects
5. Test build on puppypc

**Success Criteria:**
- Flake evaluates without errors
- Modules auto-load via import-tree
- One host builds successfully with new aspects

### Week 2: System & Desktop Aspects

**Goals:**
- Migrate system-level configuration
- Migrate desktop environment
- Test on desktop hosts

**Tasks:**
1. Migrate locale, bootloader, networking aspects
2. Migrate KDE desktop environment
3. Test on puppypc and mistylappytappy
4. Verify desktop functionality

**Success Criteria:**
- Desktop hosts build and boot
- KDE works correctly
- System services start properly

### Week 3: Gaming & Complex Aspects

**Goals:**
- Migrate gaming configuration
- Handle special hosts (Steam Deck, Raspberry Pi)
- Migrate virtualization

**Tasks:**
1. Create gaming aspects (steam, mangohud)
2. Handle Jovian for thekennel
3. Handle nixos-hardware for foodbowl
4. Migrate virtualization aspect
5. Test on gaming hosts

**Success Criteria:**
- Gaming works on puppypc
- Steam Deck (thekennel) builds
- Raspberry Pi (foodbowl) builds

### Week 4: Services & Server Migration

**Goals:**
- Migrate server services
- Complete thedogpark migration
- Test all services

**Tasks:**
1. Migrate matrix, mailserver, nginx aspects
2. Migrate security services
3. Test thedogpark build and deployment
4. Verify services work correctly

**Success Criteria:**
- All services start correctly
- Matrix federation works
- Mail delivery works
- Minecraft server runs

### Week 5: User Migration & SpecialArgs Removal

**Goals:**
- Migrate all user configurations
- Remove all specialArgs usage
- Test all hosts

**Tasks:**
1. Create user aspect modules
2. Remove specialArgs from all configurations
3. Test builds for all hosts
4. Verify home-manager configs work

**Success Criteria:**
- All hosts build successfully
- No specialArgs remaining
- All users can log in and use their configs

### Week 6: Testing, Cleanup & Documentation

**Goals:**
- Comprehensive testing
- Remove old structure
- Document new architecture

**Tasks:**
1. Run full test suite on all hosts
2. Deploy to at least one host per type
3. Remove global-configs/ directory
4. Update documentation
5. Create usage examples

**Success Criteria:**
- All hosts pass tests
- At least one host deployed successfully
- Documentation complete
- Old structure removed

---

## Migration Commands

### Setting Up the Migration Branch

```bash
# Already done - on dendritic-test branch
git status
```

### Testing Builds During Migration

```bash
# Test a specific host
nixos-rebuild build --flake .#puppypc

# Check flake validity
nix flake check

# Show flake outputs
nix flake show

# Evaluate specific configuration
nix eval .#nixosConfigurations.puppypc.config.system.build.toplevel
```

### Switching Back if Needed

```bash
# Return to main branch
git checkout main

# Keep work in dendritic-test for reference
git branch -a
```

---

## Target Directory Structure

```
.
├── flake.nix                    # Minimal flake entry point
├── flake.lock
├── README.md
├── DENDRITIC_MIGRATION.md       # This file
│
├── modules/                     # All flake-parts modules (auto-loaded)
│   ├── aspects/                 # Feature-based aspects
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   ├── browsers.nix
│   │   ├── cli-tools.nix
│   │   ├── fonts.nix
│   │   ├── git.nix
│   │   ├── kde.nix
│   │   ├── mail.nix
│   │   ├── networking.nix
│   │   ├── printing.nix
│   │   ├── spotify.nix
│   │   ├── ssh.nix
│   │   ├── thunderbird.nix
│   │   ├── virtualization.nix
│   │   ├── vscode.nix
│   │   ├── zsh.nix
│   │   ├── gaming/
│   │   │   ├── steam.nix
│   │   │   ├── mangohud.nix
│   │   │   └── mangohud/        # Incremental per-game configs
│   │   │       ├── deadlock.nix
│   │   │       └── satisfactory.nix
│   │   └── services/
│   │       ├── nginx.nix
│   │       ├── matrix.nix
│   │       ├── minecraft.nix
│   │       ├── mailserver.nix
│   │       ├── pihole.nix
│   │       └── security/
│   │           ├── fail2ban.nix
│   │           ├── crowdsec.nix
│   │           └── clamav.nix
│   │
│   ├── hosts/                   # Host-specific configurations
│   │   ├── puppypc.nix
│   │   ├── mistylappytappy.nix
│   │   ├── thedogpark.nix
│   │   ├── thekennel.nix
│   │   └── foodbowl.nix
│   │
│   ├── users/                   # User-specific aspects
│   │   ├── misty.nix
│   │   ├── steam.nix
│   │   └── wagtailpsychology.nix
│   │
│   └── system/                  # System-level base configs
│       ├── bootloader.nix
│       ├── locale.nix
│       ├── nixoptions.nix
│       └── zram.nix
│
├── hardware/                    # Hardware configurations (not auto-loaded)
│   ├── puppypc.nix
│   ├── mistylappytappy.nix
│   ├── thedogpark.nix
│   ├── thekennel.nix
│   └── foodbowl.nix
│
├── secrets/                     # sops-nix secrets (unchanged)
│   └── ...
│
└── patches/                     # Custom patches (unchanged)
    └── ...
```

---

## Example Module Templates

### Simple Aspect Module Template

```nix
# modules/aspects/git.nix
{ inputs, config, ... }:
let
  # Shared values across classes
  userName = "Mistyttm";
  userEmail = "contact@mistyttm.dev";
in
{
  # System-level packages
  flake.modules.nixos.git = {
    environment.systemPackages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
      git
      git-lfs
    ];
  };

  # Home-manager user config
  flake.modules.homeManager.git = { pkgs, ... }: {
    home.packages = with pkgs; [ stgit ];
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userName = userName;
      userEmail = userEmail;
      lfs.enable = true;
      # ... rest of config
    };
    programs.gh.enable = true;
  };
}
```

### Host Module Template

```nix
# modules/hosts/puppypc.nix
{ inputs, ... }:
{
  flake.nixosConfigurations.puppypc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Hardware config
      ../hardware/puppypc.nix
      
      # System aspects
      inputs.self.modules.nixos.git
      inputs.self.modules.nixos.kde
      inputs.self.modules.nixos.audio
      inputs.self.modules.nixos.networking
      inputs.self.modules.nixos.ssh
      
      # Gaming aspects
      inputs.self.modules.nixos.gaming
      
      # External modules
      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        # Home-manager configuration
        home-manager.users.misty = { ... }: {
          imports = with inputs.self.modules.homeManager; [
            git
            zsh
            vscode
            spotify
            # ... other home aspects
          ];
        };
      }
    ];
  };
}
```

### Minimal flake.nix Target

```nix
# flake.nix
{
  description = "NixOS configuration for Misty Rose's pack - Dendritic edition";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # ... all other inputs
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

---

## Benefits Expected

### Modularity
- Each aspect self-contained in one file
- Easy to enable/disable features per host
- Clear feature boundaries

### Shareability
- Generic aspects can be shared with community
- Easy to import aspects from others
- No host-specific coupling

### Maintainability
- No more specialArgs complexity
- Clear where each feature is configured
- Incremental feature additions

### Discoverability
- Want to know about git config? Check `modules/aspects/git.nix`
- Path names serve as documentation
- Auto-loading means no manual import tracking

### Multi-host Management
- Currently managing 5 hosts (2 desktop, 1 server, 1 Steam Deck, 1 Pi)
- Aspect-based makes it clear which features each host uses
- Easy to add new hosts by selecting aspects

---

## Risks & Mitigation

### Risk: Breaking existing hosts
**Mitigation:** Work in separate branch, test each phase, keep rollback capability

### Risk: Migration taking too long
**Mitigation:** Incremental approach, can deploy partially migrated state

### Risk: Complexity in conversion
**Mitigation:** Start with simple aspects, document patterns, ask community

### Risk: Unforeseen incompatibilities
**Mitigation:** Test thoroughly before removing old structure

---

## Success Metrics

- [ ] All 5 hosts build successfully
- [ ] All hosts can be deployed
- [ ] All services work correctly
- [ ] No specialArgs usage remaining
- [ ] All modules auto-loaded
- [ ] Documentation complete
- [ ] At least 3 aspects identified as shareable

---

## Notes & Observations

### Community Examples Referenced
- [vic/vix](https://github.com/vic/vix) - Good example of dendritic structure
- [mightyiam/infra](https://github.com/mightyiam/infra) - Creator's own config
- [drupol/nixos-x260](https://github.com/drupol/nixos-x260) - Laptop config example

### Questions for Community
- Best practices for secrets in dendritic setup?
- How to handle hardware-specific modules?
- Patterns for per-host service configurations?

### Future Enhancements
- Create "pack" aspect profiles (developer-pack, gamer-pack, server-pack)
- Extract generic gaming setup for Steam Deck
- Share KDE configuration aspects
- Create reusable mail aspect

---

## Progress Tracking

**Phase Completed:** None  
**Current Phase:** Planning  
**Blockers:** None  
**Next Steps:** Begin Phase 1 - Infrastructure Setup

**Last Updated:** 29 November 2025

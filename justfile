# Justfile - Quick command shortcuts for NixOS config management
# Install just: nix-env -iA nixpkgs.just (or it's in your devshell)
# Run: just <command>

# Default recipe - show available commands
default:
    @just --list

# ============================================================================
# Rebuild Commands
# ============================================================================

# Rebuild and switch to a specific host
rebuild host:
    sudo nixos-rebuild switch --flake .#{{host}}

# Rebuild current host (auto-detect hostname)
rebuild-current:
    sudo nixos-rebuild switch --flake .#$(hostname)

# Test build without switching
build host:
    nixos-rebuild build --flake .#{{host}}

# Build and show what would change
dry-run host:
    nixos-rebuild dry-activate --flake .#{{host}}

# ============================================================================
# Flake Commands
# ============================================================================

# Update all flake inputs
update:
    nix flake update

# Update a specific input
update-input input:
    nix flake lock --update-input {{input}}

# Check flake for errors
check:
    nix flake check

# Show flake outputs
show:
    nix flake show

# ============================================================================
# Development
# ============================================================================

# Enter dev shell
dev:
    nix develop

# Format all nix files
fmt:
    nix fmt

# Run pre-commit hooks
pre-commit:
    pre-commit run --all-files

# ============================================================================
# Topology
# ============================================================================

# Build topology diagrams
topology:
    nix build .#topology.x86_64-linux.config.output -o topology-result
    cp topology-result/*.svg topology/
    @echo "Topology diagrams updated in topology/"

# ============================================================================
# Garbage Collection
# ============================================================================

# Collect garbage (keep recent generations)
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Remove old generations (keep last 5)
gc-generations:
    sudo nix-env --delete-generations +5
    nix-env --delete-generations +5

# Optimize nix store
optimize:
    nix-store --optimise

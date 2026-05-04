# Justfile - Quick command shortcuts for NixOS config management
# Install just: nix-env -iA nixpkgs.just (or it's in your devshell)
# Run: just <command>

# Default recipe - show available commands
default:
    @just --list

# ============================================================================
# Rebuild Commands
# ============================================================================

# Rebuild and switch to a specific host using nh (shows build progress)
rebuild host:
    NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H {{host}}

# Rebuild current host (auto-detect hostname)
rebuild-current:
    NH_SHOW_ACTIVATION_LOGS=1 nh os switch .

# Test build without switching
build host:
    NH_SHOW_ACTIVATION_LOGS=1 nh os build . -H {{host}}

# Build and show what would change
dry-run host:
    NH_SHOW_ACTIVATION_LOGS=1 nh os dry-activate . -H {{host}}

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
    nh clean all --ask

# Remove old generations (keep last 5)
gc-generations:
    sudo nix-env --delete-generations +5
    nix-env --delete-generations +5

# Optimize nix store
optimize:
    nix-store --optimise

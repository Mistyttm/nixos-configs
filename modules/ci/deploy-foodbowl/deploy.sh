# Builds on the (aarch64) runner, never on the Pi; anything CI cached is just fetched.
# --no-reexec: skip re-running with the target's own nixos-rebuild.
nix run --inputs-from . nixpkgs#nixos-rebuild-ng -- switch \
  --flake .#foodbowl \
  --target-host foodbowl \
  --use-substitutes \
  --no-reexec

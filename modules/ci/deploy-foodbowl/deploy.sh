# max-jobs = 0 means this fails unless CI already cached foodbowl's closure.
# --no-reexec: the target's nixos-rebuild is aarch64 and can't run here.
nix run --inputs-from . nixpkgs#nixos-rebuild-ng -- switch \
  --flake .#foodbowl \
  --target-host foodbowl \
  --use-substitutes \
  --no-reexec

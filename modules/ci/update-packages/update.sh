set -euo pipefail

nix run nixpkgs#nix-update -- \
  "packages.x86_64-linux.${PACKAGE}" \
  --flake \
  --use-update-script

nix fmt -- "packages/${PACKAGE}"

if git diff --quiet -- "packages/${PACKAGE}"; then
  echo "changed=false" >> "$GITHUB_OUTPUT"
else
  echo "changed=true" >> "$GITHUB_OUTPUT"
fi

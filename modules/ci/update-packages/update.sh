set -euo pipefail

# nix-update wraps CppNix onto PATH, whose `flake metadata` path isn't materialised under Lix
nix shell --impure --expr "
  let pkgs = import (builtins.getFlake \"git+file://$PWD\").inputs.nixpkgs { };
  in pkgs.nix-update.override { nix = pkgs.lix; }
" -c nix-update \
  "packages.x86_64-linux.${PACKAGE}" \
  --flake \
  --use-update-script

nix fmt -- "packages/${PACKAGE}"

if git diff --quiet -- "packages/${PACKAGE}"; then
  echo "changed=false" >> "$GITHUB_OUTPUT"
else
  echo "changed=true" >> "$GITHUB_OUTPUT"
fi

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-update

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg="$dir/package.nix"

latest_rev="$(
  curl -fsSL \
    https://api.github.com/repos/vanilla-wiiu/vanilla/releases/tags/continuous \
  | jq -r '.target_commitish'
)"

latest_date="$(
  curl -fsSL \
    "https://api.github.com/repos/vanilla-wiiu/vanilla/commits/${latest_rev}" \
  | jq -r '.commit.committer.date' \
  | cut -dT -f1
)"

new_version="continuous-${latest_date}"
old_version="${UPDATE_NIX_OLD_VERSION:-$(grep -m1 'version = ' "$pkg" | sed 's/.*"\(.*\)".*/\1/')}"

if [ "$new_version" = "$old_version" ]; then
  echo "Package is already up to date: ${new_version}"
  exit 0
fi

# Update src rev via sed (only touches vanilla's rev, not drc-hostap's different hash)
old_src_rev="$(grep 'rev = ' "$pkg" | sed -n '2p' | sed 's/.*"\(.*\)".*/\1/')"
sed -i "s/rev = \"${old_src_rev}\"/rev = \"${latest_rev}\"/" "$pkg"

# nix-update handles version + hash:
# - sets version = "${new_version}"
# - re-evaluates the package (now sees updated rev from sed above)
# - derives the correct tarball URL from fetchFromGitHub's owner/repo/rev
# - downloads, computes hash, updates src.hash
nix-update "${UPDATE_NIX_ATTR_PATH:-packages.x86_64-linux.vanilla-wiiu}" \
  --flake \
  --version "${new_version}"
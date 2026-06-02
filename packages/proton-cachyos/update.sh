#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-update
# shellcheck shell=bash

set -euo pipefail

version=$(curl -fsSL "https://api.github.com/repos/CachyOS/proton-cachyos/releases" |
  jq -er 'map(select(.prerelease == false)) | .[0].tag_name | sub("^cachyos-"; "") | sub("-slr$"; "")')

nix-update --flake "$UPDATE_NIX_ATTR_PATH" --version "$version"

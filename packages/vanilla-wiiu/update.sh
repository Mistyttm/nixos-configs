#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts git

set -euo pipefail

branch="${1:?usage: update-continuous-branch.sh <branch-name>}"

attr_path="${UPDATE_NIX_ATTR_PATH:?UPDATE_NIX_ATTR_PATH not set — this script must be run via nix-update or nixpkgs's update.py, not called directly}"
pname="${UPDATE_NIX_PNAME:-$(nix eval --raw ".#${attr_path}.pname")}"

# fetchFromGitHub exposes passthru.gitRepoUrl on its result for exactly
# this purpose. Fall back to meta.homepage for fetchers that don't set it
# (e.g. a plain fetchgit src with an explicit url already).
git_url=$(nix eval --raw ".#${attr_path}.src.gitRepoUrl" 2>/dev/null || true)
if [ -z "$git_url" ]; then
  git_url="$(nix eval --raw ".#${attr_path}.meta.homepage").git"
fi

rev=$(git ls-remote "$git_url" "refs/heads/${branch}" | cut -f1)
if [ -z "$rev" ]; then
  echo "error: couldn't resolve branch '${branch}' on ${git_url}" >&2
  exit 1
fi

new_version="continuous-$(date -u +%Y-%m-%d)"

# --source-key=src scopes the edit to the top-level `src = fetchFromGitHub
# { ... }` attribute, leaving any other fetchgit/fetchFromGitHub calls in
# the same file (e.g. vendored dependency sources) untouched.
update-source-version "$pname" "$new_version" \
  --rev="$rev" \
  --source-key=src \
  --ignore-same-version

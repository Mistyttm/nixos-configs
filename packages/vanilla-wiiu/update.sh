#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts git

set -euo pipefail

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

update-source-version .#vanilla-wiiu \
  "continuous-${latest_date}" \
  --rev="$latest_rev"

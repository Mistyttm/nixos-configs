set -o pipefail

if [ -n "$DISPATCH_GROUPS" ] && [ "$DISPATCH_GROUPS" != all ]; then
  groups=$DISPATCH_GROUPS
elif [ -n "$EVENT_SCHEDULE" ]; then
  groups=$(jq -r --arg cron "$EVENT_SCHEDULE" '.[$cron][]' <<<"$CADENCES")
else
  groups=$(jq -r '[.[][]] | .[]' <<<"$CADENCES")
fi

# One commit per group; a failing group doesn't block the rest.
failed=()
for group in $groups; do
  echo "::group::Update $group"
  log="/tmp/update-$group.log"
  if ! nix run .#write-lock -- "$group" 2>&1 | tee "$log"; then
    echo "::error::tack update failed for group $group"
    failed+=("$group")
    git checkout -- .tack
  elif ! git diff --quiet -- .tack; then
    UPDATES=$(grep -E -- "->" "$log" || echo "Updated $group pins")
    git add .tack/pins.toml .tack/pins.lock.json
    git commit -m "chore(deps): update $group inputs" -m "$UPDATES"
  fi
  echo "::endgroup::"
done

# Reported after the push, so the groups that did update still land.
echo "failed=${failed[*]}" >>"$GITHUB_OUTPUT"

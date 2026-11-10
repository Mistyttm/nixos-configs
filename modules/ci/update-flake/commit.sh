if ! git diff --quiet flake.lock; then
  # Extract updated inputs from nix flake update output
  UPDATES=$(grep -E "Updated.*input" /tmp/flake-update.log || echo "Updated flake.lock")

  git add flake.lock
  git commit -m "chore(deps): update flake inputs" -m "$UPDATES"
fi

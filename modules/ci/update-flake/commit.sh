if ! git diff --quiet -- .tack; then
  # Extract updated pins from tack update output
  UPDATES=$(grep -E -- "->" /tmp/flake-update.log || echo "Updated tack pins")

  git add .tack/pins.toml .tack/pins.lock.json
  git commit -m "chore(deps): update flake inputs" -m "$UPDATES"
fi

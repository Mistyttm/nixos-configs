errors="$(grep -aE '^error:|builder for .* failed|cannot build|dependency .* failed' \
  build-results/build-shared.log | sort -u | head -n 50 || true)"

{
  echo "## ❌ Shared derivation build failed"
  echo
  echo "### Errors"
  echo
  echo '```text'
  echo "${errors:-Unable to parse build errors}"
  echo
  echo "--- last 100 log lines ---"
  tail -n 100 build-results/build-shared.log | tr -d '\000' || true
  echo '```'
} >> "$GITHUB_STEP_SUMMARY"

echo "$errors" | while IFS= read -r error; do
  [ -n "$error" ] && echo "::error title=Shared derivation build failure::$error"
done


set -euo pipefail

: > build.log
if nix build ".#packages.x86_64-linux.${PACKAGE}" --no-link --print-build-logs --json > >(tee build.json) 2> >(tee build.log >&2); then
  jq -r '.[].outputs[]' build.json \
    | xargs -I{} nix-store --query --requisites {} \
    | sort -u \
    | cachix push opinionatedcache
  echo "package_failed=false" >> "$GITHUB_OUTPUT"
else
  log_excerpt=$(tail -n 120 build.log | sed 's/\r$//')
  {
    echo "failure_log_excerpt<<EOF"
    echo "${log_excerpt:-No stderr output captured. Check workflow logs for details.}"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo "failure_reason=build_failed" >> "$GITHUB_OUTPUT"
  echo "failure_summary=Build failed for this free package. Opening a PR for manual review." >> "$GITHUB_OUTPUT"
  echo "package_failed=true" >> "$GITHUB_OUTPUT"
fi

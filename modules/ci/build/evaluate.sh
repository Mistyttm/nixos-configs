set -o pipefail

mkdir -p eval-results

nix-eval-jobs \
  --flake .#hydraJobs \
  --workers 2 \
  --max-memory-size 2048 \
  > eval-results/results.jsonl || true

errors=$(jq -s '
  map(select(has("error")))
' eval-results/results.jsonl)

if [ "$(echo "$errors" | jq length)" -gt 0 ]; then
  {
    echo "## ❌ Nix Evaluation Failed"
    echo
    echo "The following Hydra jobs failed evaluation:"
    echo

    echo "$errors" | jq -r '
      .[] |
      "### \(.attr // \"unknown\")\n\n```\n\(.error)\n```\n"
    '
  } >> "$GITHUB_STEP_SUMMARY"

  echo "$errors" | jq -r '
    .[] |
    "::error title=Nix evaluation failed (\(.attr // \"unknown\"))::\(.error | gsub("\n"; " "))"
  '

  exit 1
fi

echo "## ✅ Nix Evaluation Passed" >> "$GITHUB_STEP_SUMMARY"
echo "" >> "$GITHUB_STEP_SUMMARY"
echo "All Hydra jobs evaluated successfully." >> "$GITHUB_STEP_SUMMARY"


# GitHub starts `shell: bash` with -e. Turn it off so a failed build
# does not abort the script before its exit status is handled.
set +e
set -uo pipefail

mkdir -p build-results
: > build-results/dryrun.log
: > build-results/build-shared.log

# Dry run. The output stays out of the Actions log: it lists every
# substitutable path (tens of thousands of lines).
xargs -a plan/shared.txt -n 2000 \
  nix-store --realise --dry-run >> build-results/dryrun.log 2>&1

awk '
  /will be built:$/ { f = 1; next }
  /^[^ ]/           { f = 0 }
  f && /\.drv$/     { gsub(/^ +/, ""); print }
' build-results/dryrun.log | sort -u > build-results/to-build.txt

to_build=$(wc -l < build-results/to-build.txt)
echo "Derivations that need building: $to_build"
echo "- Shared derivations that actually needed building: **$to_build**" >> "$GITHUB_STEP_SUMMARY"

if [ "$to_build" -eq 0 ]; then
  echo "Nothing to build."
  exit 0
fi

echo "::group::Derivations to build"
cat build-results/to-build.txt
echo "::endgroup::"

# Realise ONLY the derivations that need building, in one invocation
# so nix schedules them properly. Realising the whole shared closure
# also downloaded the output of every substitutable derivation
# (~17k paths, over 100 GiB) and filled /nix before the builds were
# done. Nix fetches just the build inputs it needs for these.
mapfile -t todo < build-results/to-build.txt

nix-store --realise \
  --keep-going \
  --max-jobs 2 \
  --no-build-output \
  --option log-lines 80 \
  "${todo[@]}" \
  2>&1 | tee -a build-results/build-shared.log

exit "${PIPESTATUS[0]}"


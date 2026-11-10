set -euo pipefail

mkdir -p plan/systems

# Full derivation closure for one system's toplevel.
# This is independent of substituter availability and gives us every
# derivation required to realise the system.
closure_drvs() {
  local system="$1"
  local toplevel_drv

  toplevel_drv="$(nix eval --raw \
    ".#nixosConfigurations.${system}.config.system.build.toplevel.drvPath")"

  nix-store --query --requisites "$toplevel_drv" \
  | awk '/\.drv$/ { print }' \
  | sort -u
}

for system in $(jq -r '.[]' <<< "$SYSTEMS"); do
  closure_drvs "$system" > "plan/systems/$system.txt"
  echo "$system: $(wc -l < "plan/systems/$system.txt") derivations in closure"
done

# Needed by 2+ systems == shared derivation work across hosts.
cat plan/systems/*.txt | sort | uniq -d > plan/shared.txt

per_system_total=$(cat plan/systems/*.txt | wc -l)
unique_total=$(cat plan/systems/*.txt | sort -u | wc -l)
shared=$(wc -l < plan/shared.txt)

echo "shared=$shared" >> "$GITHUB_OUTPUT"

{
  echo "## Build plan"
  echo
  echo "| System | Derivations in closure |"
  echo "|---|---|"
  for f in plan/systems/*.txt; do
    echo "| $(basename "$f" .txt) | $(wc -l < "$f") |"
  done
  echo
  echo "- Shared by 2+ systems: **$shared**"
  echo "- Cross-system duplicate derivation references: **$((per_system_total - unique_total))**"
} >> "$GITHUB_STEP_SUMMARY"


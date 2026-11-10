set -o pipefail

mkdir -p build-results

nix build \
  .#nixosConfigurations.${SYSTEM}.config.system.build.toplevel \
  --keep-going \
  --log-format internal-json \
  2>&1 | { grep --line-buffered '"action":"msg"' || true; } > build-results/build.jsonl

exit ${PIPESTATUS[0]}


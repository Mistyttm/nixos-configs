set -euo pipefail

nix build .#topology.x86_64-linux.config.output -o topology-result

shopt -s nullglob
svgs=(topology-result/*.svg)
if [ "${#svgs[@]}" -eq 0 ]; then
  echo "::error::nix-topology produced no SVGs"
  exit 1
fi
mkdir -p topology
cp "${svgs[@]}" topology/

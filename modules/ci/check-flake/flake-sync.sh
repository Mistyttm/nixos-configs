nix run .#write-flake
if ! git diff --quiet -- flake.nix; then
  echo "::error::flake.nix is out of sync with modules/inputs.nix (or outputs.nix). Run 'nix run .#write-flake' locally and commit the result."
  git diff -- flake.nix
  exit 1
fi

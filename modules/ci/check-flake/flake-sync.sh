nix run .#write-tack
if ! git diff --quiet -- .tack/pins.toml; then
  echo "::error::.tack/pins.toml is out of sync with flake-file.inputs. Run 'nix run .#write-lock' locally and commit the result."
  git diff -- .tack/pins.toml
  exit 1
fi

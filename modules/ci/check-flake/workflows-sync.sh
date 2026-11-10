nix run .#write-workflows
if ! git diff --quiet -- .github/workflows; then
  echo "::error::.github/workflows is out of sync with modules/ci/. Run 'nix run .#write-workflows' locally and commit the result."
  git diff -- .github/workflows
  exit 1
fi

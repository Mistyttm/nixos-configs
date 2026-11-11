# Unlike `git diff`, this also catches new untracked diagrams.
if [ -z "$(git status --porcelain -- topology)" ]; then
  echo "changed=false" >> "$GITHUB_OUTPUT"
else
  echo "changed=true" >> "$GITHUB_OUTPUT"
fi

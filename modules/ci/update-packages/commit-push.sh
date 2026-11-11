set -euo pipefail

git add "packages/${PACKAGE}"

if git diff --cached --quiet; then
  echo "No staged changes to commit"
  exit 0
fi

git commit -m "${COMMIT_MESSAGE}"
git pull --rebase origin main
git push origin HEAD:main

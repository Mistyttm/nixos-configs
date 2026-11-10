set +e
set -uo pipefail

if [ ! -s build-results/to-build.txt ]; then
  echo "Nothing was built locally; nothing to push."
  exit 0
fi

# Outputs of derivations whose build failed do not exist; skip them.
# (`[ -e ] && echo` as the last command of the loop would return 1
# and fail the whole step, so use an if.)
xargs -a build-results/to-build.txt -n 256 nix-store --query --outputs 2>/dev/null \
  | while IFS= read -r path; do
      if [ -e "$path" ]; then echo "$path"; fi
    done \
  | sort -u > build-results/push-paths.txt

count=$(wc -l < build-results/push-paths.txt)
echo "Pushing $count store paths"
if [ "$count" -gt 0 ]; then
  cachix push opinionatedcache < build-results/push-paths.txt
fi


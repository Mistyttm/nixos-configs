set -euo pipefail

package_file="packages/${PACKAGE}"

old_version=$(git diff -- "$package_file" | sed -nE 's/^-[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";/\1/p' | head -n1)
new_version=$(git diff -- "$package_file" | sed -nE 's/^\+[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";/\1/p' | head -n1)

if [ -n "${old_version}" ] && [ -n "${new_version}" ]; then
  echo "message=update(packages/${PACKAGE}): ${old_version} -> ${new_version}" >> "$GITHUB_OUTPUT"
else
  echo "message=update(packages/${PACKAGE}): package update" >> "$GITHUB_OUTPUT"
fi

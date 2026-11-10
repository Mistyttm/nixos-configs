{
  echo "## ❌ Build failed: ${SYSTEM}"
  echo
  echo "### Errors"
  echo
  echo '```text'

  sed -n 's/^@nix //p' build-results/build.jsonl \
  | jq -R -r '
    fromjson? | select(.action == "msg" and .level == 0)
    |
    if (.msg | type) == "string"
    then .msg
    else (.msg.text // tostring)
    end
  ' \
  | sed -E 's/\x1b\[[0-9;]*m//g' \
  || echo "Unable to parse build errors"

  echo '```'
} >> "$GITHUB_STEP_SUMMARY"

sed -n 's/^@nix //p' build-results/build.jsonl \
| jq -R -r '
  fromjson? | select(.action == "msg" and .level == 0)
  |
  if (.msg | type) == "string"
  then .msg
  else (.msg.text // tostring)
  end
' \
| sed -E 's/\x1b\[[0-9;]*m//g' \
| while IFS= read -r error; do
    echo "::error title=Nix build failure::$error"
  done


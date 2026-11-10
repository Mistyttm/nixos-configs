if git diff --quiet HEAD origin/main; then
  echo "changed=false" >> $GITHUB_OUTPUT
else
  echo "changed=true" >> $GITHUB_OUTPUT
fi

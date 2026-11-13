install -d -m 700 ~/.ssh
printf '%s\n' "$DEPLOY_KEY" > ~/.ssh/deploy
chmod 600 ~/.ssh/deploy
printf '%s\n' "$KNOWN_HOSTS" > ~/.ssh/known_hosts

# foodbowl is only reachable over WireGuard, via thedogpark.
cat > ~/.ssh/config <<'CONF'
Host thedogpark
  HostName mistyttm.dev
  User deploy
Host foodbowl
  HostName 10.100.0.6
  User root
  ProxyJump thedogpark
Host *
  IdentityFile ~/.ssh/deploy
  IdentitiesOnly yes
  StrictHostKeyChecking yes
  ServerAliveInterval 15
CONF

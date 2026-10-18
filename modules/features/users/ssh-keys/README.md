# misty's SSH keys

Each machine has its own keypair, fully managed by this repo:

- **Public key:** `ssh-keys/<hostname>.pub` (this directory). Every `*.pub` file here is added to `users.users.misty.openssh.authorizedKeys` on every host that imports `self.nixosModules.misty`.
- **Private key:** `secrets/ssh-<hostname>.yaml`, under the key `ssh_key`. `.sops.yaml` encrypts each of these files to the admin key and that one host only. sops-nix decrypts it to `/run/secrets/misty-ssh-key`, and `/etc/ssh/ssh_config` points misty's `ssh` at it.

Add a machine (can be done from any machine holding the admin age key):

```sh
host=thedogpark
ssh-keygen -t ed25519 -N "" -C "misty@$host" -f /tmp/$host
cp /tmp/$host.pub modules/features/users/ssh-keys/$host.pub
sops secrets/ssh-$host.yaml   # add:  ssh_key: |   then paste /tmp/$host, indented
shred -u /tmp/$host /tmp/$host.pub
git add modules/features/users/ssh-keys/$host.pub secrets/ssh-$host.yaml
```

A new host also needs its own `secrets/ssh-<hostname>\.yaml` rule in `.sops.yaml`, above the catch-all rule.

Revoke a machine: delete its `.pub` file and `secrets/ssh-<hostname>.yaml`, then rebuild the hosts.

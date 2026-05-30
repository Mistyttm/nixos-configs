# WireGuard {#module-doggate-wireguard}

Source: modules/features/nixosModules/system-essentials/networking/wireguard.nix

This module provides a host-profile driven WireGuard setup under
`doggate.wireguard`. It selects a profile from the current hostname unless a
profile is set explicitly, then wires the matching interface, secrets, firewall
rules, and helper packages into the system.

## Usage {#module-doggate-wireguard-usage}

Enable the module on a host and let the hostname select the profile:

```nix
{
  doggate.wireguard = {
    enable = true;
  };
}
```

If you want to override the selected profile, set `profile` directly:

```nix
{
  doggate.wireguard = {
    enable = true;
    profile = "thedogpark";
  };
}
```

## Options {#module-doggate-wireguard-options}

`enable`
: Enables the unified WireGuard configuration.

`profile`
: Overrides the profile selected from `networking.hostName`.

`extraAllowedUDPPorts`
: Additional UDP ports to open on top of the selected profile.

`extraInterfaces`
: Extra or overriding entries merged into `networking.wireguard.interfaces`.

## Profiles {#module-doggate-wireguard-profiles}

The module currently defines profiles for `puppypc`, `puppylaptop`,
`thedogpark`, and `thekennel`.

`puppypc`
: Client profile for the desktop host. Uses `wg0`, a `10.100.0.4/24` address,
  and the shared `thedogpark` peer.

`puppylaptop`
: Client profile for the laptop host. Uses `wg0`, a `10.100.0.3/24` address,
  and the shared `thedogpark` peer.

`thedogpark`
: Hub profile. Listens on port `51820`, trusts `wg0`, and peers the other hosts
  onto `10.100.0.0/24`.

`thekennel`
: Client profile for the home server. Uses `wg0`, a `10.100.0.2/24` address,
  and the shared `thedogpark` peer.

## Notes {#module-doggate-wireguard-notes}

The module creates the WireGuard secrets in sops, installs `wireguard-tools`,
and keeps the service tied to `network-online.target`. Firewall permissions come
from the selected profile plus any extra UDP ports you add.

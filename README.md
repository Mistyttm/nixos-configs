<p align="center">
  <picture>
    <source srcset="https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-rainbow.svg">
    <img
      src="https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-rainbow.svg"
      alt="Our logo" width="200px">
    </img>
  </picture>
</p>

# NixOS Configs | Misty

![Static Badge](https://img.shields.io/badge/Made_for_NixOS-white?style=for-the-badge&logo=nixos&logoSize=auto) ![Static Badge](https://img.shields.io/badge/Nix_Flakes-lightblue?style=for-the-badge&logo=nixos&logoSize=auto)

[![Build](https://github.com/Mistyttm/nixos-configs/actions/workflows/build.yml/badge.svg)](https://github.com/Mistyttm/nixos-configs/actions/workflows/build.yml)
[![Update Flake](https://github.com/Mistyttm/nixos-configs/actions/workflows/update-flake.yml/badge.svg)](https://github.com/Mistyttm/nixos-configs/actions/workflows/update-flake.yml)
[![Topology](https://github.com/Mistyttm/nixos-configs/actions/workflows/update-topology.yml/badge.svg)](https://github.com/Mistyttm/nixos-configs/actions/workflows/update-topology.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

This repository contains the configuration files for my NixOS systems. The configurations are managed using flakes.

See [COMMITTING.md](COMMITTING.md) for commit message guidelines.


## Directory Structure

```
.
├── flake.nix              # Flake definition and host configurations
├── hosts/                 # Per-host configurations
│   ├── puppypc/           # Main desktop
│   ├── mistylappytappy/   # Gaming laptop
│   ├── thedogpark/        # Sydney VPS
│   └── thekennel/         # Home server
├── global-configs/        # Shared configurations
│   ├── fonts/             # Font configuration
│   ├── programs/          # User programs (browsers, games, etc.)
│   ├── shell/             # Shell config (zsh, starship, etc.)
│   ├── system/            # System config (DE, networking, etc.)
│   └── users/             # User definitions
├── modules/               # Custom NixOS/home-manager modules
├── patches/               # Package patches
├── secrets/               # Encrypted secrets (sops)
└── topology/              # Infrastructure diagrams
```

## Infrastructure

<details>
<summary>Click to view network topology</summary>

![Network Topology](./topology/main.svg)

</details>

<details>
<summary>Click to view network-centric diagram</summary>

![Network View](./topology/network.svg)

</details>

> Generated with [nix-topology](https://github.com/oddlama/nix-topology). Rebuild with: `nix build .#topology.x86_64-linux.config.output`

## Hosts

### `puppypc` - Main Desktop

|              |                                                     |
| ------------ | --------------------------------------------------- |
| **Hardware** | AMD Ryzen 7 7800X3D, 32GB DDR5, RTX 3090            |
| **Kernel**   | Zen                                                 |
| **Desktop**  | KDE Plasma                                          |
| **Services** | WiVRn, SlimeVR                                      |
| **Gaming**   | Steam, Lutris, Minecraft, Clone Hero, YARG, Dolphin |

### `mistylappytappy` - Gaming Laptop

|             |                             |
| ----------- | --------------------------- |
| **Kernel**  | Zen                         |
| **Desktop** | KDE Plasma                  |
| **Gaming**  | Steam (portable), Minecraft |

### `thedogpark` - Sydney VPS

|              |                                                       |
| ------------ | ----------------------------------------------------- |
| **Kernel**   | Hardened                                              |
| **Services** | Matrix Synapse, Minecraft, nginx, WireGuard, fail2ban |

### `thekennel` - Home Server

|              |                                                                               |
| ------------ | ----------------------------------------------------------------------------- |
| **Hardware** | NVIDIA GPU (CUDA)                                                             |
| **Kernel**   | Zen                                                                           |
| **Desktop**  | KDE Plasma (Jovian)                                                           |
| **Services** | Jellyfin, Sonarr, Radarr, Prowlarr, qBittorrent, Jellyseerr, nginx, WireGuard |

## To-Do

- [ ] Enable `foodbowl` (Raspberry Pi 4) configuration
- [ ] Convert systems to btrfs
- [x] ~~Clean up commented code and leftover TODOs~~
- [x] ~~Implement secrets management~~ (sops-nix working across hosts)
- [x] ~~Add infrastructure diagrams~~ (nix-topology)

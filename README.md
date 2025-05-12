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

This repository contains the configuration files for my NixOS systems. The configurations are managed using flakes. I still have a number of things left to do, the configuration files are not modularised and are a bit of a mess. I will be working on cleaning them up and making them more modular in the future.

## Hosts

### `puppypc` - Main Desktop

- Hardware:
  - AMD Ryzen 7 7800X3D
  - 32GB DDR5 RAM
  - RTX 3090
  - B650 Gaming Plus wifi Mobo
- Headset:
  - Meta Quest 2

### `mistylappytappy` - Laptop

### `thedogpark` - Server

## To-Do

- [ ] Modularise configuration files
- [ ] Add configuration for raspberry pi 4
  - [ ] Convert raspberrypi 4 to nixos
- [ ] Clean up configuration files
- [ ] Properly implement secrets management (currently only working in a single file on `thedogpark`)
- [ ] Look at conveting systems to `btrfs`

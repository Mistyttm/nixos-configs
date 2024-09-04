<img 
    style="display: block; 
           margin-left: auto;
           margin-right: auto;"
    src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fnixos.wiki%2Fimages%2Fthumb%2F2%2F20%2FHome-nixos-logo.png%2F207px-Home-nixos-logo.png&f=1&nofb=1&ipt=57218c10fd20f2193a3385efb04888fed0e0215a6818bd268720e4f3860dfffe&ipo=images" 
    alt="Our logo">
</img>

# NixOS Configs | Misty

![Static Badge](https://img.shields.io/badge/Made_for_NixOS-white?style=for-the-badge&logo=nixos&logoSize=auto) ![Static Badge](https://img.shields.io/badge/Nix_Flakes-lightblue?style=for-the-badge&logo=nixos&logoSize=auto)

This repository contains the configuration files for my NixOS systems. The configurations are managed using flakes. I still have a number of things left to do, the configuration files are not modularised and are a bit of a mess. I will be working on cleaning them up and making them more modular in the future.

## Hosts

 - `puppypc` - Main Desktop
 - `mistylappytappy` - Laptop
 - `thedogpark` - Server

## To-Do

 - [ ] Modularise configuration files
 - [ ] Add configuration for raspberry pi 4
   - [ ] Convert raspberrypi 4 to nixos
 - [ ] Clean up configuration files
 - [ ] Properly implement secrets management (currently only working in a single file on `thedogpark`)

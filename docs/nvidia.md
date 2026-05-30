# NVIDIA {#module-hardware-nvidia-custom}

Source: modules/features/nixosModules/hardware/nvidia.nix

This custom module wraps the standard NixOS NVIDIA stack into a single
`hardware.nvidia-custom` option set. It is intended for systems that need the
proprietary NVIDIA driver, PRIME offload on laptops, or a small amount of extra
GPU-related setup beyond the stock module defaults.

## Usage {#module-hardware-nvidia-custom-usage}

A typical desktop or laptop setup looks like this:

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    open = true;
    modesetting = true;
    driverChannel = "beta";
    blacklistNova = true;
    nvidiaContainerToolkit = true;
  };
}
```

For laptops with an integrated GPU and a dedicated NVIDIA GPU, enable PRIME and
fill in the PCI bus IDs:

```nix
{
  hardware.nvidia-custom.prime = {
    enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
```

## Options {#module-hardware-nvidia-custom-options}

`enable`
: Enables the custom NVIDIA configuration.

`driverChannel`
: Selects which NVIDIA package set to use. `stable` uses
  `config.boot.kernelPackages.nvidiaPackages.stable`, `beta` uses
  `config.boot.kernelPackages.nvidiaPackages.beta`, and `latest` uses
  `config.boot.kernelPackages.nvidiaPackages.latest`.

`open`
: Uses the open-source NVIDIA kernel modules when supported by the GPU.

`modesetting`
: Enables kernel mode setting. The NixOS NVIDIA wiki recommends leaving this on
  for most setups.

`powerManagement.enable`
: Enables NVIDIA power management.

`powerManagement.finegrained`
: Enables fine-grained power management for newer GPUs.

`prime.enable`
: Enables PRIME offload for hybrid graphics systems.

`prime.intelBusId`
: PCI bus ID of the integrated Intel GPU.

`prime.nvidiaBusId`
: PCI bus ID of the NVIDIA GPU.

`forceFullCompositionPipeline`
: Forces the full composition pipeline, which can help with screen tearing on
  some X11 setups.

`blacklistNova`
: Blacklists Nova, NovaCore, and Nouveau. Use this when you need to avoid the
  newer in-kernel NVIDIA stack on affected kernels.

`extraGraphicsPackages`
: Extra packages added to `hardware.graphics.extraPackages`.

`nvidiaContainerToolkit`
: Enables the NVIDIA container toolkit for Docker workloads.

## Notes {#module-hardware-nvidia-custom-notes}

The module follows the general guidance from the NixOS NVIDIA wiki:

- Use `hardware.nvidia.open = true` on supported cards when you want the open
  kernel modules.
- Keep `hardware.nvidia.modesetting.enable = true` unless you have a specific
  reason not to.
- Use PRIME offload on laptops with an integrated GPU and a dedicated NVIDIA
  GPU.
- Set `hardware.nvidia.powerManagement.enable = true` or
  `hardware.nvidia.powerManagement.finegrained = true` only when you need the
  suspend and power-saving behavior they provide.
- Set `blacklistNova = true` on systems that need to avoid the Nova/NovaCore
  drivers introduced in newer kernels.

This module still relies on the normal NixOS NVIDIA options under the hood, so
the usual NVIDIA caveats still apply: unfree userspace packages are required,
Wayland support depends on driver and compositor version, and PRIME bus IDs must
match the actual PCI topology of the machine.

{inputs, ...}: {
  # Don't make this follow our nixpkgs, the `pinned` overlay builds against the input's own pin so
  # the kernels hit lantian's binary cache.
  flake-file.inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.nixosModules.cachyosKernel = {
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    nix.settings = {
      substituters = ["https://cache.lantian.pub/lantian"];
      trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
    };
  };
}

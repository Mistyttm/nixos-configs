{ ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
    ./cpu.nix
  ];
}


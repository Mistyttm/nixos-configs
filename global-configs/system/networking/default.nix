{
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./networkmanager.nix
    ./ssh.nix
    ./bluetooth.nix
    ./dns.nix
  ];
}

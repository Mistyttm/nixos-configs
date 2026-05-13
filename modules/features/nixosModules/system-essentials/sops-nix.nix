{ inputs, ... }:

{
  flake.nixosModules.sops =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        sops
      ];
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    };
}

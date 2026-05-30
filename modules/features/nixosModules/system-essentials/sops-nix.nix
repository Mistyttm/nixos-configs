{ ... }:

{
  flake.nixosModules.sops =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        sops
      ];
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    };
}

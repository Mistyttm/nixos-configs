{ ... }: {
  imports = [
    ./mailserver.nix
    ./minecraft.nix
    ./nginx.nix
    ./services.nix
  ];
}
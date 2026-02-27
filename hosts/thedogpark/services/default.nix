{ ... }:
{
  imports = [
    # ./mailserver.nix
    ./minecraft.nix
    ./motd.nix
    ./nginx.nix
    ./services.nix
    ./fail2ban.nix
    ./wireguard.nix
  ];
}

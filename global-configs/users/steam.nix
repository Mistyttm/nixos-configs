{ ... }:
{
  users.users.steam = {
    isNormalUser = true;
    description = "Steam";
    home = "/var/lib/steamuser";
    createHome = true;
    group = "steam";
  };
  users.groups.steam = {};
}

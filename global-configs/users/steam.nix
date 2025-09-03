{ ... }:
{
  users.users.steam = {
    isSystemUser = true;
    description = "Steam";
    home = "/var/lib/steamuser";
    createHome = true;
    group = "steam";
  };
  users.groups.steam = {};
}

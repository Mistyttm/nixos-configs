{ ... }:
{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    group = "usenet";
    user = "usenet";
  };
}

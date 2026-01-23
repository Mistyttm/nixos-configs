{ ... }:
{
  services.tautulli = {
    enable = true;
    port = 8181;
    dataDir = "/var/lib/tautulli";
    group = "media";
    openFirewall = true;
  };
}

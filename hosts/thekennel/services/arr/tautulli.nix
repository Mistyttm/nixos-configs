{ ... }:
{
  services.tautulli = {
    enable = true;
    port = 8181;
    dataDir = "/var/lib/tautulli";
    user = "tautulli";
    group = "media";
  };
}

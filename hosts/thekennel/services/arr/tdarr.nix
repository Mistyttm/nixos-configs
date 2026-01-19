{ ... }:
{
  services.tdarr = {
    enable = true;
    # Server component
    server = {
      enable = true;
      port = 8266;
    };
    # Node component (does the actual transcoding)
    node = {
      enable = true;
      port = 8267;
      serverIP = "127.0.0.1";
    };
    dataDir = "/var/lib/tdarr";
  };
}

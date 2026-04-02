{ pkgs, ... }:
let
  localRoot = "/mnt/localExpansion";
in
{
  services.tdarr = {
    enable = true;

    # Keep data under /data to match existing layout expectations.
    dataDir = "/data/tdarr";

    server = {
      enable = true;
      package = pkgs.tdarr-server;
      serverIP = "0.0.0.0";
      serverPort = 8266;
      webUIPort = 8265;
      openFirewall = true;
    };

    nodes = {
      internal = {
        enable = true;
        package = pkgs.tdarr-node;
        name = "InternalNode";
        serverURL = "http://127.0.0.1:8266";
      };

      external = {
        enable = true;
        package = pkgs.tdarr-node;
        name = "ExternalNode";
        serverURL = "http://127.0.0.1:8266";
      };
    };
  };

  users.users.tdarr = {
    uid = 985;
    extraGroups = [
      "media"
      "video"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${localRoot}/tdarr 0755 tdarr media -"
  ];
}

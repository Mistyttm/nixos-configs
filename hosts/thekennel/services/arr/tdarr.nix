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
        workers = {
          transcodeCPU = 0;
          transcodeGPU = 2;
          healthcheckCPU = 1;
          healthcheckGPU = 1;
        };
      };

      external = {
        enable = true;
        package = pkgs.tdarr-node;
        name = "ExternalNode";
        serverURL = "http://127.0.0.1:8266";
        workers = {
          transcodeCPU = 0;
          transcodeGPU = 2;
          healthcheckCPU = 1;
          healthcheckGPU = 1;
        };
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
    # Ensure ownership is corrected after migration from docker volumes.
    "Z /data/tdarr 0750 tdarr tdarr -"
    "d ${localRoot}/tdarr 0755 tdarr media -"
  ];

  systemd.services."tdarr-node-external".serviceConfig.ReadWritePaths = [
    "${localRoot}/tdarr" # cache
    "${localRoot}/tv" # library
    "/mnt/media/Movies" # library
  ];
  systemd.services."tdarr-node-internal".serviceConfig.ReadWritePaths = [
    "${localRoot}/tdarr" # cache
    "${localRoot}/tv" # library
    "/mnt/media/Movies" # library
  ];
  systemd.services."tdarr-server".serviceConfig.ReadWritePaths = [
    "${localRoot}/tdarr" # cache
    "${localRoot}/tv" # library
    "/mnt/media/Movies" # library
  ];
}

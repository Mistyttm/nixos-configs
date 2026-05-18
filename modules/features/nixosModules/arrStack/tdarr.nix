{ ... }:

{
  flake.nixosModules.tdarr =
    { pkgs, lib, ... }:
    let
      localRoot = "/mnt/localExpansion";
      nasRoot = "/mnt/media";

      libraries = [
        "${localRoot}/tdarr" # cache
        "${localRoot}/tv" # library
        "${localRoot}/movies" # library
        "${nasRoot}/Movies" # library
        "${nasRoot}/TV" # library
      ];

      tdarrVersion = "2.74.01";
    in
    {
      services.tdarr = {
        enable = true;

        # Keep data under /data to match existing layout expectations.
        dataDir = "/data/tdarr";

        server = {
          enable = true;
          package = pkgs.tdarr-server.overrideAttrs (
            finalAttrs: _oldAttrs: {
              version = tdarrVersion;
              src = pkgs.fetchzip {
                url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Server.zip";
                hash = "sha256-PnRu0Xr95vFwSVVgHnE+k6+T5gu5m2qQo8DoIxFm2Bs=";
                stripRoot = false;
              };
            }
          );
          serverIP = "0.0.0.0";
          serverPort = 8266;
          webUIPort = 8265;
          openFirewall = true;
        };

        nodes = {
          internal = {
            enable = true;
            package = pkgs.tdarr-node.overrideAttrs (
              finalAttrs: _oldAttrs: {
                version = tdarrVersion;
                src = pkgs.fetchzip {
                  url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Node.zip";
                  hash = "sha256-0AdD+8pCfPyLMEEEbzPRZFzv+V1Kkg/Qxnt+nngD1Ds=";
                  stripRoot = false;
                };
              }
            );
            name = "InternalNode";
            serverURL = "http://127.0.0.1:8266";
            workers = {
              transcodeCPU = 0;
              transcodeGPU = 2;
              healthcheckCPU = 2;
              healthcheckGPU = 2;
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

      systemd.services."tdarr-node-internal".serviceConfig = lib.mkMerge [
        {
          ReadWritePaths = libraries;
          MemoryAccounting = true;
          MemoryMax = "4G";
        }
      ];

      systemd.services."tdarr-server".serviceConfig = lib.mkMerge [
        {
          ReadWritePaths = libraries;
          MemoryAccounting = true;
          MemoryMax = "4G";
        }
      ];
    };
}
